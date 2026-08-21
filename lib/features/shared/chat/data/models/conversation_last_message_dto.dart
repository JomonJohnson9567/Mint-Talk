import '../../domain/entities/conversation_last_message_entity.dart';
import '../../domain/entities/message_status.dart';

class ConversationLastMessageDto {
  final String id;
  final String content;
  final MessageStatus status;
  final DateTime? createdAt;

  const ConversationLastMessageDto({
    required this.id,
    required this.content,
    required this.status,
    this.createdAt,
  });

  factory ConversationLastMessageDto.fromJson(Map<String, dynamic> json) {
    return ConversationLastMessageDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      status: MessageStatus.fromString(json['status']?.toString()),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  ConversationLastMessageEntity toEntity() {
    return ConversationLastMessageEntity(
      id: id,
      content: content,
      status: status,
      createdAt: createdAt,
    );
  }
}
