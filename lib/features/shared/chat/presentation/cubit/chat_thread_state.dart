import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/predefined_message_entity.dart';

enum ChatThreadStatus { initial, loading, loaded, failure }

class ChatThreadState extends Equatable {
  final ChatThreadStatus status;
  final String recipientId;
  final String recipientName;
  final String? recipientAvatarUrl;
  final String? conversationId;
  final List<MessageEntity> messages;
  final List<PredefinedMessageEntity> predefinedMessages;
  final String? myUserId;
  final int messagesPage;
  final int messagesTotalPages;
  final bool isLoadingMoreMessages;
  final Set<String> sendingClientMessageIds;
  final Set<String> failedClientMessageIds;
  final String? errorMessage;

  const ChatThreadState({
    this.status = ChatThreadStatus.initial,
    required this.recipientId,
    required this.recipientName,
    this.recipientAvatarUrl,
    this.conversationId,
    this.messages = const [],
    this.predefinedMessages = const [],
    this.myUserId,
    this.messagesPage = 1,
    this.messagesTotalPages = 1,
    this.isLoadingMoreMessages = false,
    this.sendingClientMessageIds = const {},
    this.failedClientMessageIds = const {},
    this.errorMessage,
  });

  bool get hasMoreMessages => messagesPage < messagesTotalPages;

  ChatThreadState copyWith({
    ChatThreadStatus? status,
    String? recipientId,
    String? recipientName,
    String? recipientAvatarUrl,
    String? conversationId,
    List<MessageEntity>? messages,
    List<PredefinedMessageEntity>? predefinedMessages,
    String? myUserId,
    int? messagesPage,
    int? messagesTotalPages,
    bool? isLoadingMoreMessages,
    Set<String>? sendingClientMessageIds,
    Set<String>? failedClientMessageIds,
    String? errorMessage,
  }) {
    return ChatThreadState(
      status: status ?? this.status,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      recipientAvatarUrl: recipientAvatarUrl ?? this.recipientAvatarUrl,
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      predefinedMessages: predefinedMessages ?? this.predefinedMessages,
      myUserId: myUserId ?? this.myUserId,
      messagesPage: messagesPage ?? this.messagesPage,
      messagesTotalPages: messagesTotalPages ?? this.messagesTotalPages,
      isLoadingMoreMessages:
          isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      sendingClientMessageIds:
          sendingClientMessageIds ?? this.sendingClientMessageIds,
      failedClientMessageIds:
          failedClientMessageIds ?? this.failedClientMessageIds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recipientId,
    recipientName,
    recipientAvatarUrl,
    conversationId,
    messages,
    predefinedMessages,
    myUserId,
    messagesPage,
    messagesTotalPages,
    isLoadingMoreMessages,
    sendingClientMessageIds,
    failedClientMessageIds,
    errorMessage,
  ];
}
