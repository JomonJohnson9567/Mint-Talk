import '../../domain/entities/conversation_participant_entity.dart';

class ConversationParticipantDto {
  final String id;
  final String fullName;
  final String avatarUrl;
  final String role;

  const ConversationParticipantDto({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    required this.role,
  });

  factory ConversationParticipantDto.fromJson(Map<String, dynamic> json) {
    return ConversationParticipantDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }

  ConversationParticipantEntity toEntity() {
    return ConversationParticipantEntity(
      id: id,
      fullName: fullName,
      avatarUrl: avatarUrl,
      role: role,
    );
  }
}
