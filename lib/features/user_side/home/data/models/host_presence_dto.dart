import '../../domain/entities/host_presence_entity.dart';

class HostPresenceDto {
  final String userId;
  final String role;
  final String status;
  final int lastSeen;
  final int updatedAt;
  final bool busy;
  final bool audioAvailable;
  final bool videoAvailable;
  final String state;

  const HostPresenceDto({
    required this.userId,
    required this.role,
    required this.status,
    required this.lastSeen,
    required this.updatedAt,
    required this.busy,
    required this.audioAvailable,
    required this.videoAvailable,
    required this.state,
  });

  factory HostPresenceDto.fromJson(Map<String, dynamic> json) {
    return HostPresenceDto(
      userId: (json['userId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      status: (json['status'] ?? 'offline').toString(),
      lastSeen: json['lastSeen'] is int ? json['lastSeen'] : 0,
      updatedAt: json['updatedAt'] is int ? json['updatedAt'] : 0,
      busy: json['busy'] == true || json['state'] == 'busy',
      audioAvailable:
          json['audio_available'] == true || json['audioAvailable'] == true,
      videoAvailable:
          json['video_available'] == true || json['videoAvailable'] == true,
      state: (json['state'] ?? (json['busy'] == true ? 'busy' : '')).toString(),
    );
  }

  HostPresenceEntity toEntity() {
    return HostPresenceEntity(
      userId: userId,
      role: role,
      status: status,
      lastSeen: lastSeen,
      updatedAt: updatedAt,
      busy: busy,
      audioAvailable: audioAvailable,
      videoAvailable: videoAvailable,
      state: state,
    );
  }
}
