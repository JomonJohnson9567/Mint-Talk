import 'package:mint_talk/core/utils/json_date_parser.dart';
import 'package:mint_talk/core/utils/json_number_parser.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_socket_event.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';

/// Data-layer DTO for real-time call status events received over WebSocket.
///
/// Handles all key name variations the backend may send
/// (`agoraToken` | `rtcToken` | `token`) so the domain layer
/// and Cubit never need to touch raw socket payloads.
class CallSocketEventDto {
  final String callId;
  final String status;
  final CallType? callType;
  final String? agoraChannel;
  final String? agoraToken;
  final int? duration;
  final int? billedUnits;
  final int? totalPointsDebited;
  final String? endReason;
  final String? hostId;
  final String? callerId;
  final DateTime? activeAt;

  const CallSocketEventDto({
    required this.callId,
    required this.status,
    this.callType,
    this.agoraChannel,
    this.agoraToken,
    this.duration,
    this.billedUnits,
    this.totalPointsDebited,
    this.endReason,
    this.hostId,
    this.callerId,
    this.activeAt,
  });

  factory CallSocketEventDto.fromJson(Map<String, dynamic> json) {
    final rawType = (json['callType'] ?? json['call_type'] ?? json['type'])?.toString();
    return CallSocketEventDto(
      callId: (json['callId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      callType: rawType != null ? CallType.fromString(rawType) : null,
      agoraChannel:
          (json['agoraChannel'] ?? json['channelName'])?.toString(),
      agoraToken: (json['agoraToken'] ?? json['rtcToken'] ?? json['token'])
          ?.toString(),
      duration: JsonNumberParser.parseInt(json['duration']),
      billedUnits: JsonNumberParser.parseInt(
        json['billedUnits'] ?? json['billedMinutes'],
      ),
      totalPointsDebited: JsonNumberParser.parseInt(json['totalPointsDebited']),
      endReason: json['endReason']?.toString(),
      hostId: json['hostId']?.toString(),
      callerId: json['callerId']?.toString(),
      activeAt: JsonDateParser.parse(json['activeAt']),
    );
  }

  CallSocketEvent toEntity() {
    return CallSocketEvent(
      callId: callId,
      status: status,
      callType: callType,
      agoraChannel: agoraChannel,
      agoraToken: agoraToken,
      duration: duration,
      billedUnits: billedUnits,
      totalPointsDebited: totalPointsDebited,
      endReason: endReason,
      hostId: hostId,
      callerId: callerId,
      activeAt: activeAt,
    );
  }
}
