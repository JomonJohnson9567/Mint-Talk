import '../../domain/entities/call_session_entity.dart';

class CallSessionDto {
  final String callId;
  final String? agoraChannel;
  final String? agoraToken;
  final String status;
  final String callType;
  final int? duration;
  final int? billedMinutes;
  final int? totalPointsDebited;
  final int? ratePerMinute;
  final String? endReason;
  final String? hostId;
  final String? callerId;

  const CallSessionDto({
    required this.callId,
    this.agoraChannel,
    this.agoraToken,
    required this.status,
    required this.callType,
    this.duration,
    this.billedMinutes,
    this.totalPointsDebited,
    this.ratePerMinute,
    this.endReason,
    this.hostId,
    this.callerId,
  });

  factory CallSessionDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return CallSessionDto(
      callId: (data['callId'] ?? data['id'] ?? data['_id'] ?? '').toString(),
      agoraChannel: data['agoraChannel']?.toString(),
      agoraToken: data['agoraToken']?.toString(),
      status: (data['status'] ?? 'ringing').toString(),
      callType: (data['callType'] ?? 'audio').toString(),
      duration: data['duration'] is int
          ? data['duration']
          : int.tryParse(data['duration']?.toString() ?? ''),
      billedMinutes: data['billedMinutes'] is int
          ? data['billedMinutes']
          : int.tryParse(data['billedMinutes']?.toString() ?? ''),
      totalPointsDebited: data['totalPointsDebited'] is int
          ? data['totalPointsDebited']
          : int.tryParse(data['totalPointsDebited']?.toString() ?? ''),
      ratePerMinute: data['ratePerMinute'] is int
          ? data['ratePerMinute']
          : int.tryParse(data['ratePerMinute']?.toString() ?? ''),
      endReason: data['endReason']?.toString(),
      hostId: data['hostId']?.toString(),
      callerId: data['callerId']?.toString(),
    );
  }

  CallSessionEntity toEntity() {
    return CallSessionEntity(
      callId: callId,
      agoraChannel: agoraChannel,
      agoraToken: agoraToken,
      status: status,
      callType: callType,
      duration: duration ?? 0,
      billedMinutes: billedMinutes ?? 0,
      totalPointsDebited: totalPointsDebited ?? 0,
      ratePerMinute: ratePerMinute ?? 0,
      endReason: endReason ?? '',
      hostId: hostId ?? '',
      callerId: callerId ?? '',
    );
  }
}
