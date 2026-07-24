import '../../domain/entities/call_participant_entity.dart';

class CallParticipantDto {
  final String id;
  final String fullName;
  final String phone;
  final String role;
  final String avatarUrl;

  const CallParticipantDto({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.avatarUrl,
  });

  factory CallParticipantDto.fromJson(Map<String, dynamic> json) {
    return CallParticipantDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
    );
  }

  CallParticipantEntity toEntity() {
    return CallParticipantEntity(
      id: id,
      fullName: fullName,
      phone: phone,
      role: role,
      avatarUrl: avatarUrl,
    );
  }
}
