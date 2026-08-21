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
  final int? billedMinutes;
  final int? totalPointsDebited;
  final String? endReason;
  final String? hostId;
  final String? callerId;

  const CallSocketEventDto({
    required this.callId,
    required this.status,
    this.callType,
    this.agoraChannel,
    this.agoraToken,
    this.duration,
    this.billedMinutes,
    this.totalPointsDebited,
    this.endReason,
    this.hostId,
    this.callerId,
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
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? ''),
      billedMinutes: json['billedMinutes'] is int
          ? json['billedMinutes']
          : int.tryParse(json['billedMinutes']?.toString() ?? ''),
      totalPointsDebited: json['totalPointsDebited'] is int
          ? json['totalPointsDebited']
          : int.tryParse(json['totalPointsDebited']?.toString() ?? ''),
      endReason: json['endReason']?.toString(),
      hostId: json['hostId']?.toString(),
      callerId: json['callerId']?.toString(),
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
      billedMinutes: billedMinutes,
      totalPointsDebited: totalPointsDebited,
      endReason: endReason,
      hostId: hostId,
      callerId: callerId,
    );
  }
}
