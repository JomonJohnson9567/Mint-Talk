import '../../domain/entities/conversation_entity.dart';
import 'conversation_last_message_dto.dart';
import 'conversation_participant_dto.dart';

class ConversationDto {
  final String id;
  final List<ConversationParticipantDto> participants;
  final Map<String, int> unreadCounts;
  final ConversationLastMessageDto? lastMessage;
  final DateTime? lastMessageAt;

  const ConversationDto({
    required this.id,
    required this.participants,
    required this.unreadCounts,
    this.lastMessage,
    this.lastMessageAt,
  });

  factory ConversationDto.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'] as List? ?? const [];
    final rawUnreadCounts =
        json['unreadCounts'] as Map<String, dynamic>? ?? const {};
    final rawLastMessage = json['lastMessage'];

    return ConversationDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      participants: rawParticipants
          .whereType<Map<String, dynamic>>()
          .map(ConversationParticipantDto.fromJson)
          .toList(),
      unreadCounts: rawUnreadCounts.map(
        (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0),
      ),
      lastMessage: rawLastMessage is Map<String, dynamic>
          ? ConversationLastMessageDto.fromJson(rawLastMessage)
          : null,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
    );
  }

  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      participants: participants.map((p) => p.toEntity()).toList(),
      unreadCounts: unreadCounts,
      lastMessage: lastMessage?.toEntity(),
      lastMessageAt: lastMessageAt,
    );
  }
}
