import '../../domain/entities/call_log_entity.dart';
import 'call_participant_dto.dart';

class CallLogDto {
  final String id;
  final CallParticipantDto? caller;
  final CallParticipantDto? host;
  final String status;
  final String callType;
  final int duration;
  final int billedMinutes;
  final num totalPointsDebited;
  final String endReason;
  final DateTime? createdAt;

  const CallLogDto({
    required this.id,
    this.caller,
    this.host,
    required this.status,
    required this.callType,
    required this.duration,
    required this.billedMinutes,
    required this.totalPointsDebited,
    required this.endReason,
    this.createdAt,
  });

  factory CallLogDto.fromJson(Map<String, dynamic> json) {
    return CallLogDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      caller: json['callerId'] is Map<String, dynamic>
          ? CallParticipantDto.fromJson(json['callerId'] as Map<String, dynamic>)
          : null,
      host: json['hostId'] is Map<String, dynamic>
          ? CallParticipantDto.fromJson(json['hostId'] as Map<String, dynamic>)
          : null,
      status: (json['status'] ?? '').toString(),
      callType: (json['callType'] ?? 'audio').toString(),
      duration: json['duration'] is int ? json['duration'] : 0,
      billedMinutes: json['billedMinutes'] is int ? json['billedMinutes'] : 0,
      totalPointsDebited: json['totalPointsDebited'] is num ? json['totalPointsDebited'] : 0,
      endReason: (json['endReason'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  CallLogEntity toEntity() {
    return CallLogEntity(
      id: id,
      caller: caller?.toEntity(),
      host: host?.toEntity(),
      status: status,
      callType: callType,
      duration: duration,
      billedMinutes: billedMinutes,
      totalPointsDebited: totalPointsDebited,
      endReason: endReason,
      createdAt: createdAt,
    );
  }
}
