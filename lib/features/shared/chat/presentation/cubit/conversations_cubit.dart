import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/conversation_last_message_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/watch_new_messages_usecase.dart';
import 'conversations_state.dart';

const _kPageLimit = 20;

@injectable
class ConversationsCubit extends Cubit<ConversationsState> {
  final GetConversationsUseCase _getConversationsUseCase;
  final IAuthLocalDataSource _authLocalDataSource;

  StreamSubscription<MessageEntity>? _newMessageSub;

  ConversationsCubit(
    this._getConversationsUseCase,
    this._authLocalDataSource,
    WatchNewMessagesUseCase watchNewMessagesUseCase,
  ) : super(const ConversationsState()) {
    _newMessageSub = watchNewMessagesUseCase().listen(_onNewMessage);
  }

  Future<void> loadConversations() async {
    _safeEmit(state.copyWith(status: ConversationsStatus.loading));

    final myUserId = state.myUserId ?? await _authLocalDataSource.getUserId();

    final result = await _getConversationsUseCase(
      const GetConversationsParams(page: 1, limit: _kPageLimit),
    );

    result.fold(
      (failure) => _safeEmit(
        state.copyWith(
          status: ConversationsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (paginated) => _safeEmit(
        state.copyWith(
          status: ConversationsStatus.loaded,
          conversations: paginated.items,
          myUserId: myUserId,
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ConversationsStatus.loadingMore) {
      return;
    }

    _safeEmit(state.copyWith(status: ConversationsStatus.loadingMore));

    final result = await _getConversationsUseCase(
      GetConversationsParams(page: state.page + 1, limit: _kPageLimit),
    );

    result.fold(
      (failure) => _safeEmit(state.copyWith(status: ConversationsStatus.loaded)),
      (paginated) => _safeEmit(
        state.copyWith(
          status: ConversationsStatus.loaded,
          conversations: [...state.conversations, ...paginated.items],
          page: paginated.page,
          totalPages: paginated.totalPages,
        ),
      ),
    );
  }

  void _onNewMessage(MessageEntity message) {
    final index = state.conversations.indexWhere(
      (c) => c.id == message.conversationId,
    );

    if (index == -1) {
      // Not one of the currently loaded conversations — most likely a
      // brand new thread started this session. Cheap enough to just
      // refetch page 1 rather than reconstruct a conversation entry from
      // a bare message payload (which has no participant info).
      loadConversations();
      return;
    }

    final existing = state.conversations[index];
    final isMine = message.senderId == state.myUserId;
    final updated = ConversationEntity(
      id: existing.id,
      participants: existing.participants,
      unreadCounts: isMine
          ? existing.unreadCounts
          : {
              ...existing.unreadCounts,
              if (state.myUserId != null)
                state.myUserId!: existing.unreadCountFor(state.myUserId!) + 1,
            },
      lastMessage: ConversationLastMessageEntity(
        id: message.id,
        content: message.content,
        status: message.status,
        createdAt: message.createdAt,
      ),
      lastMessageAt: message.createdAt,
    );

    final reordered = [
      updated,
      ...state.conversations.where((c) => c.id != existing.id),
    ];

    _safeEmit(state.copyWith(conversations: reordered));
  }

  void _safeEmit(ConversationsState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _newMessageSub?.cancel();
    return super.close();
  }
}
