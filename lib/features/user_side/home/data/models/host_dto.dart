import '../../domain/entities/host_entity.dart';
import 'host_presence_dto.dart';

class HostDto {
  final String id;
  final String fullName;
  final String phone;
  final String avatarUrl;
  final String selfieUrl;
  final String dob;
  final String gender;
  final num audioRate;
  final num videoRate;
  final bool isAudioAllowed;
  final bool isVideoAllowed;
  final HostPresenceDto? presence;

  const HostDto({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.avatarUrl,
    required this.selfieUrl,
    required this.dob,
    required this.gender,
    required this.audioRate,
    required this.videoRate,
    required this.isAudioAllowed,
    required this.isVideoAllowed,
    this.presence,
  });

  factory HostDto.fromJson(Map<String, dynamic> json) {
    return HostDto(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      selfieUrl: (json['selfieUrl'] ?? '').toString(),
      dob: (json['dob'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      audioRate: json['audioRate'] is num ? json['audioRate'] : 0,
      videoRate: json['videoRate'] is num ? json['videoRate'] : 0,
      isAudioAllowed: json['isAudioAllowed'] == true,
      isVideoAllowed: json['isVideoAllowed'] == true,
      presence: json['presence'] is Map<String, dynamic>
          ? HostPresenceDto.fromJson(json['presence'] as Map<String, dynamic>)
          : null,
    );
  }

  HostEntity toEntity() {
    return HostEntity(
      id: id,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      selfieUrl: selfieUrl,
      dob: dob,
      gender: gender,
      audioRate: audioRate,
      videoRate: videoRate,
      isAudioAllowed: isAudioAllowed,
      isVideoAllowed: isVideoAllowed,
      presence: presence?.toEntity(),
    );
  }
}
