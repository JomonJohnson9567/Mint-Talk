import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_status.dart';
import '../../domain/usecases/get_conversation_messages_usecase.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_predefined_messages_usecase.dart';
import '../../domain/usecases/mark_conversation_read_usecase.dart';
import '../../domain/usecases/mark_messages_delivered_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/watch_new_messages_usecase.dart';
import 'chat_thread_state.dart';

const _kMessagesPageLimit = 20;

/// Not `@injectable` — takes required per-screen constructor args
/// (recipientId/recipientName/conversationId), which trips a known DI
/// codegen issue in this project for cubits mixing `@injectable` with
/// required primitive constructor params. Construct manually per screen,
/// pulling usecases from `getIt` individually.
class ChatThreadCubit extends Cubit<ChatThreadState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetConversationMessagesUseCase _getConversationMessagesUseCase;
  final GetPredefinedMessagesUseCase _getPredefinedMessagesUseCase;
  final MarkConversationReadUseCase _markConversationReadUseCase;
  final MarkMessagesDeliveredUseCase _markMessagesDeliveredUseCase;
  final GetConversationsUseCase _getConversationsUseCase;
  final IAuthLocalDataSource _authLocalDataSource;

  StreamSubscription<MessageEntity>? _newMessageSub;

  ChatThreadCubit({
    required SendMessageUseCase sendMessageUseCase,
    required GetConversationMessagesUseCase getConversationMessagesUseCase,
    required GetPredefinedMessagesUseCase getPredefinedMessagesUseCase,
    required MarkConversationReadUseCase markConversationReadUseCase,
    required MarkMessagesDeliveredUseCase markMessagesDeliveredUseCase,
    required GetConversationsUseCase getConversationsUseCase,
    required WatchNewMessagesUseCase watchNewMessagesUseCase,
    required IAuthLocalDataSource authLocalDataSource,
    required String recipientId,
    required String recipientName,
    String? recipientAvatarUrl,
    String? conversationId,
  }) : _sendMessageUseCase = sendMessageUseCase,
       _getConversationMessagesUseCase = getConversationMessagesUseCase,
       _getPredefinedMessagesUseCase = getPredefinedMessagesUseCase,
       _markConversationReadUseCase = markConversationReadUseCase,
       _markMessagesDeliveredUseCase = markMessagesDeliveredUseCase,
       _getConversationsUseCase = getConversationsUseCase,
       _authLocalDataSource = authLocalDataSource,
       super(
         ChatThreadState(
           recipientId: recipientId,
           recipientName: recipientName,
           recipientAvatarUrl: recipientAvatarUrl,
           conversationId: conversationId,
         ),
       ) {
    _newMessageSub = watchNewMessagesUseCase().listen(_onNewMessage);
  }

  Future<void> init() async {
    _safeEmit(state.copyWith(status: ChatThreadStatus.loading));

    final myUserId = await _authLocalDataSource.getUserId();
    _safeEmit(state.copyWith(myUserId: myUserId));

    unawaited(_loadPredefinedMessages());

    var resolvedConversationId = state.conversationId;
    resolvedConversationId ??= await _resolveExistingConversationId();

    if (resolvedConversationId == null) {
      _safeEmit(state.copyWith(status: ChatThreadStatus.loaded));
      return;
    }

    _safeEmit(state.copyWith(conversationId: resolvedConversationId));
    await _loadMessagesPage(1, append: false);
    await _markReadAndAckDelivery();
    _safeEmit(state.copyWith(status: ChatThreadStatus.loaded));
  }

  Future<void> selectPrompt(int index) async {
    if (index < 0 || index >= state.predefinedMessages.length) return;
    await _sendContent(state.predefinedMessages[index].text);
  }

  /// Re-sends a previously failed message (identified by the optimistic
  /// [clientMessageId] it was given). Drops the failed placeholder and
  /// sends a fresh attempt with a new clientMessageId.
  Future<void> retryMessage(String clientMessageId) async {
    final failed = state.messages.where((m) => m.id == clientMessageId);
    if (failed.isEmpty) return;
    final content = failed.first.content;

    _safeEmit(
      state.copyWith(
        messages: state.messages
            .where((m) => m.id != clientMessageId)
            .toList(),
        failedClientMessageIds: {...state.failedClientMessageIds}
          ..remove(clientMessageId),
      ),
    );

    await _sendContent(content);
  }

  Future<void> _sendContent(String content) async {
    final clientMessageId = 'local_${DateTime.now().microsecondsSinceEpoch}';
    final myUserId = state.myUserId ?? '';

    final optimistic = MessageEntity(
      id: clientMessageId,
      conversationId: state.conversationId ?? '',
      senderId: myUserId,
      recipientId: state.recipientId,
      content: content,
      status: MessageStatus.sent,
      clientMessageId: clientMessageId,
      createdAt: DateTime.now(),
    );

    _safeEmit(
      state.copyWith(
        messages: [...state.messages, optimistic],
        sendingClientMessageIds: {
          ...state.sendingClientMessageIds,
          clientMessageId,
        },
      ),
    );

    final result = await _sendMessageUseCase(
      SendMessageParams(
        recipientId: state.recipientId,
        content: content,
        clientMessageId: clientMessageId,
      ),
    );

    result.fold(
      (failure) {
        _safeEmit(
          state.copyWith(
            sendingClientMessageIds: {...state.sendingClientMessageIds}
              ..remove(clientMessageId),
            failedClientMessageIds: {
              ...state.failedClientMessageIds,
              clientMessageId,
            },
            errorMessage: failure.message,
          ),
        );
      },
      (sent) {
        // The socket's `new_message` push can beat this REST response back
        // (it's typically pushed to the sender too, for multi-device sync),
        // already adding `sent` under its real id via `_onNewMessage`. Drop
        // the optimistic placeholder and merge (not naively replace) so
        // that race can't leave both the placeholder AND the real message
        // in the list as two bubbles.
        final withoutOptimistic = state.messages
            .where((m) => m.id != clientMessageId)
            .toList();
        _safeEmit(
          state.copyWith(
            messages: _mergeMessages([sent], base: withoutOptimistic),
            conversationId: state.conversationId ?? sent.conversationId,
            sendingClientMessageIds: {...state.sendingClientMessageIds}
              ..remove(clientMessageId),
          ),
        );
      },
    );
  }

  Future<void> loadMoreMessages() async {
    if (!state.hasMoreMessages ||
        state.isLoadingMoreMessages ||
        state.conversationId == null) {
      return;
    }
    _safeEmit(state.copyWith(isLoadingMoreMessages: true));
    await _loadMessagesPage(state.messagesPage + 1, append: true);
    _safeEmit(state.copyWith(isLoadingMoreMessages: false));
  }

  Future<void> refreshMessages() async {
    if (state.conversationId == null) return;
    await _loadMessagesPage(1, append: false);
    await _markReadAndAckDelivery();
  }

  /// Handles a message pushed over the socket for ANY conversation — only
  /// applied here if it belongs to this thread. Before a conversation id is
  /// resolved (a brand-new thread), matched by recipient id instead.
  void _onNewMessage(MessageEntity message) {
    final matchesThread = state.conversationId != null
        ? message.conversationId == state.conversationId
        : (message.senderId == state.recipientId ||
              message.recipientId == state.recipientId);

    if (!matchesThread) return;

    _safeEmit(
      state.copyWith(
        messages: _mergeMessages([message]),
        conversationId: state.conversationId ?? message.conversationId,
      ),
    );

    if (message.senderId != state.myUserId) {
      _markReadAndAckDelivery();
    }
  }

  Future<void> _loadPredefinedMessages() async {
    final result = await _getPredefinedMessagesUseCase(NoParams());
    result.fold(
      (_) {},
      (predefined) =>
          _safeEmit(state.copyWith(predefinedMessages: predefined.messages)),
    );
  }

  Future<String?> _resolveExistingConversationId() async {
    final result = await _getConversationsUseCase(
      const GetConversationsParams(page: 1, limit: 20),
    );
    return result.fold((_) => null, (paginated) {
      for (final conversation in paginated.items) {
        if (conversation.participants.any((p) => p.id == state.recipientId)) {
          return conversation.id;
        }
      }
      return null;
    });
  }

  Future<void> _loadMessagesPage(int page, {required bool append}) async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;

    final result = await _getConversationMessagesUseCase(
      GetConversationMessagesParams(
        conversationId: conversationId,
        page: page,
        limit: _kMessagesPageLimit,
      ),
    );

    result.fold(
      (failure) {
        if (!append) {
          _safeEmit(state.copyWith(errorMessage: failure.message));
        }
      },
      (paginated) {
        _safeEmit(
          state.copyWith(
            messages: _mergeMessages(paginated.items),
            messagesPage: paginated.page,
            messagesTotalPages: paginated.totalPages,
          ),
        );
      },
    );
  }

  Future<void> _markReadAndAckDelivery() async {
    final conversationId = state.conversationId;
    if (conversationId == null) return;

    await _markConversationReadUseCase(
      MarkConversationReadParams(conversationId: conversationId),
    );

    final myUserId = state.myUserId;
    final undeliveredIds = state.messages
        .where((m) => m.senderId != myUserId && m.status == MessageStatus.sent)
        .map((m) => m.id)
        .toList();

    if (undeliveredIds.isEmpty) return;

    final result = await _markMessagesDeliveredUseCase(
      MarkMessagesDeliveredParams(messageIds: undeliveredIds),
    );

    result.fold((_) {}, (deliveredIds) {
      final updated = state.messages.map((m) {
        if (deliveredIds.contains(m.id) && m.status == MessageStatus.sent) {
          return m.copyWith(status: MessageStatus.delivered);
        }
        return m;
      }).toList();
      _safeEmit(state.copyWith(messages: updated));
    });
  }

  List<MessageEntity> _mergeMessages(
    List<MessageEntity> incoming, {
    List<MessageEntity>? base,
  }) {
    final byId = <String, MessageEntity>{
      for (final m in base ?? state.messages) m.id: m,
    };
    for (final m in incoming) {
      byId[m.id] = m;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  void _safeEmit(ChatThreadState newState) {
    if (!isClosed) emit(newState);
  }

  @override
  Future<void> close() {
    _newMessageSub?.cancel();
    return super.close();
  }
}
