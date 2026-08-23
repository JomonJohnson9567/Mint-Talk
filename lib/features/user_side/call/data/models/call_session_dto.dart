import 'package:mint_talk/core/utils/json_number_parser.dart';
import '../../domain/entities/call_session_entity.dart';
import '../../domain/entities/call_type.dart';

class CallSessionDto {
  final String callId;
  final String? agoraChannel;
  final String? agoraToken;
  final String status;
  final CallType callType;
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
    final rawCallType = (data['callType'] ?? data['call_type'] ?? data['type'])?.toString();

    return CallSessionDto(
      callId: (data['callId'] ?? data['id'] ?? data['_id'] ?? '').toString(),
      agoraChannel: data['agoraChannel']?.toString() ?? data['channelName']?.toString(),
      agoraToken: data['agoraToken']?.toString() ??
          data['token']?.toString() ??
          data['rtcToken']?.toString(),
      status: (data['status'] ?? 'ringing').toString(),
      callType: CallType.fromString(rawCallType),
      duration: JsonNumberParser.parseInt(data['duration']),
      billedMinutes: JsonNumberParser.parseInt(data['billedMinutes']),
      totalPointsDebited: JsonNumberParser.parseInt(data['totalPointsDebited']),
      ratePerMinute: JsonNumberParser.parseInt(data['ratePerMinute']),
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
