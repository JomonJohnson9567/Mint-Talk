import 'package:equatable/equatable.dart';
import 'call_type.dart';

/// Domain entity representing a real-time call status event
/// received from the server via WebSocket.
///
/// This entity is produced by the data layer (from [CallSocketEventDto])
/// and consumed by the Cubit. It must contain NO Flutter or Dio imports.
class CallSocketEvent extends Equatable {
  final String callId;
  final String status; // accepted | active | ended | rejected | missed | cancelled | insufficient_balance
  final CallType? callType;
  final String? agoraChannel;
  final String? agoraToken;
  final int? duration;
  final int? billedMinutes;
  final int? totalPointsDebited;
  final String? endReason;
  final String? hostId;
  final String? callerId;

  const CallSocketEvent({
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

  @override
  List<Object?> get props => [
        callId,
        status,
        callType,
        agoraChannel,
        agoraToken,
        duration,
        billedMinutes,
        totalPointsDebited,
        endReason,
        hostId,
        callerId,
      ];
}
