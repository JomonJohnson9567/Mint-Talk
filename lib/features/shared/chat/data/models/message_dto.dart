import '../../domain/entities/message_entity.dart';
import '../../domain/entities/message_status.dart';

class MessageDto {
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

  const MessageDto({
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

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return MessageDto(
      id: (data['_id'] ?? data['id'] ?? '').toString(),
      conversationId: (data['conversationId'] ?? '').toString(),
      senderId: (data['senderId'] ?? '').toString(),
      recipientId: (data['recipientId'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      status: MessageStatus.fromString(data['status']?.toString()),
      clientMessageId: data['clientMessageId']?.toString(),
      readAt: data['readAt'] != null
          ? DateTime.tryParse(data['readAt'].toString())
          : null,
      createdAt:
          DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.tryParse(data['updatedAt'].toString())
          : null,
    );
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      recipientId: recipientId,
      content: content,
      status: status,
      clientMessageId: clientMessageId,
      readAt: readAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
