import 'package:equatable/equatable.dart';
import 'message_status.dart';

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String content;
  final MessageStatus status;
  final String? clientMessageId;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.status,
    this.clientMessageId,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
  });

  bool isMine(String myUserId) => senderId == myUserId;

  MessageEntity copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? recipientId,
    String? content,
    MessageStatus? status,
    String? clientMessageId,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      status: status ?? this.status,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    recipientId,
    content,
    status,
    clientMessageId,
    readAt,
    createdAt,
    updatedAt,
  ];
}
