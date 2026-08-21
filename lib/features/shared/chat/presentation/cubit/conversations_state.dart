import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';

enum ConversationsStatus { initial, loading, loaded, loadingMore, failure }

class ConversationsState extends Equatable {
  final ConversationsStatus status;
  final List<ConversationEntity> conversations;
  final String? myUserId;
  final int page;
  final int totalPages;
  final String? errorMessage;

  const ConversationsState({
    this.status = ConversationsStatus.initial,
    this.conversations = const [],
    this.myUserId,
    this.page = 1,
    this.totalPages = 1,
    this.errorMessage,
  });

  bool get isLoading =>
      status == ConversationsStatus.initial ||
      status == ConversationsStatus.loading;

  bool get hasMore => page < totalPages;

  ConversationsState copyWith({
    ConversationsStatus? status,
    List<ConversationEntity>? conversations,
    String? myUserId,
    int? page,
    int? totalPages,
    String? errorMessage,
  }) {
    return ConversationsState(
      status: status ?? this.status,
      conversations: conversations ?? this.conversations,
      myUserId: myUserId ?? this.myUserId,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    conversations,
    myUserId,
    page,
    totalPages,
    errorMessage,
  ];
}
