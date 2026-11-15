import 'package:equatable/equatable.dart';
import 'call_type.dart';

/// Domain entity representing a real-time call status event
/// received from the server via WebSocket.
///
/// This entity is produced by the data layer (from [CallSocketEventDto])
/// and consumed by the Cubit. It must contain NO Flutter or Dio imports.
class CallSocketEvent extends Equatable {
  final String callId;
  final String
  status; // accepted | active | ended | failed | rejected | missed | cancelled | insufficient_balance
  final CallType? callType;
  final String? agoraChannel;
  final String? agoraToken;
  final int? duration;
  final int? billedUnits;
  final int? totalPointsDebited;
  final String? endReason;
  final String? hostId;
  final String? callerId;

  /// Server time billing started (`active` events only). The in-call timer
  /// counts from this, not from when this device saw the transition.
  final DateTime? activeAt;

  const CallSocketEvent({
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

  @override
  List<Object?> get props => [
    callId,
    status,
    callType,
    agoraChannel,
    agoraToken,
    duration,
    billedUnits,
    totalPointsDebited,
    endReason,
    hostId,
    callerId,
    activeAt,
  ];
}
