import 'package:mint_talk/core/utils/json_date_parser.dart';
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
  final int? billedUnits;
  final int? totalPointsDebited;
  final int? ratePerMinute;
  final String? endReason;
  final String? hostId;
  final String? callerId;
  final int? agoraUid;
  final int? connectionTimeoutSeconds;
  final int? tokenExpiresInSeconds;
  final DateTime? activeAt;
  final DateTime? ringExpiresAt;

  const CallSessionDto({
    required this.callId,
    this.agoraChannel,
    this.agoraToken,
    required this.status,
    required this.callType,
    this.duration,
    this.billedUnits,
    this.totalPointsDebited,
    this.ratePerMinute,
    this.endReason,
    this.hostId,
    this.callerId,
    this.agoraUid,
    this.connectionTimeoutSeconds,
    this.tokenExpiresInSeconds,
    this.activeAt,
    this.ringExpiresAt,
  });

  factory CallSessionDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawCallType = (data['callType'] ?? data['call_type'] ?? data['type'])
        ?.toString();

    return CallSessionDto(
      callId: (data['callId'] ?? data['id'] ?? data['_id'] ?? '').toString(),
      agoraChannel:
          data['agoraChannel']?.toString() ?? data['channelName']?.toString(),
      agoraToken:
          data['token']?.toString() ??
          data['agoraToken']?.toString() ??
          data['rtcToken']?.toString(),
      status: (data['status'] ?? 'ringing').toString(),
      callType: CallType.fromString(rawCallType),
      duration: JsonNumberParser.parseInt(data['duration']),
      billedUnits: JsonNumberParser.parseInt(
        data['billedUnits'] ?? data['billedMinutes'],
      ),
      totalPointsDebited: JsonNumberParser.parseInt(data['totalPointsDebited']),
      ratePerMinute: JsonNumberParser.parseInt(data['ratePerMinute']),
      endReason: data['endReason']?.toString(),
      hostId: _participantId(data['hostId']),
      callerId: _participantId(data['callerId']),
      agoraUid: JsonNumberParser.parseInt(data['agoraUid'] ?? data['uid']),
      connectionTimeoutSeconds: JsonNumberParser.parseInt(
        data['connectionTimeoutSeconds'] ?? data['connectTimeoutSeconds'],
      ),
      tokenExpiresInSeconds: JsonNumberParser.parseInt(
        data['tokenExpiresInSeconds'] ?? data['expiresInSeconds'],
      ),
      activeAt: JsonDateParser.parse(data['activeAt']),
      ringExpiresAt: JsonDateParser.parse(data['ringExpiresAt']),
    );
  }

  /// `GET /calls/:id` populates participants (`{_id, phone, fullName, …}`)
  /// while other endpoints send the bare id string; both yield the id.
  static String? _participantId(Object? raw) {
    if (raw is Map) {
      final id = raw['_id'] ?? raw['id'];
      return id?.toString();
    }
    return raw?.toString();
  }

  CallSessionEntity toEntity() {
    return CallSessionEntity(
      callId: callId,
      agoraChannel: agoraChannel,
      agoraToken: agoraToken,
      status: status,
      callType: callType,
      duration: duration ?? 0,
      billedUnits: billedUnits ?? 0,
      totalPointsDebited: totalPointsDebited ?? 0,
      ratePerMinute: ratePerMinute ?? 0,
      endReason: endReason ?? '',
      hostId: hostId ?? '',
      callerId: callerId ?? '',
      agoraUid: agoraUid,
      connectionTimeoutSeconds: connectionTimeoutSeconds,
      tokenExpiresInSeconds: tokenExpiresInSeconds,
      activeAt: activeAt,
      ringExpiresAt: ringExpiresAt,
    );
  }
}
