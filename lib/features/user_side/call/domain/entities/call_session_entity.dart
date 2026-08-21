import 'package:equatable/equatable.dart';
import 'call_type.dart';

class CallSessionEntity extends Equatable {
  final String callId;
  final String? agoraChannel;
  final String? agoraToken;
  final String status; // ringing | accepted | active | ended | rejected | missed | insufficient_balance
  final CallType callType;
  final int duration;
  final int billedMinutes;
  final int totalPointsDebited;
  final int ratePerMinute;
  final String endReason;
  final String hostId;
  final String callerId;

  const CallSessionEntity({
    required this.callId,
    this.agoraChannel,
    this.agoraToken,
    required this.status,
    required this.callType,
    required this.duration,
    required this.billedMinutes,
    required this.totalPointsDebited,
    required this.ratePerMinute,
    required this.endReason,
    required this.hostId,
    required this.callerId,
  });

  CallSessionEntity copyWith({
    String? callId,
    String? agoraChannel,
    String? agoraToken,
    String? status,
    CallType? callType,
    int? duration,
    int? billedMinutes,
    int? totalPointsDebited,
    int? ratePerMinute,
    String? endReason,
    String? hostId,
    String? callerId,
  }) {
    return CallSessionEntity(
      callId: callId ?? this.callId,
      agoraChannel: agoraChannel ?? this.agoraChannel,
      agoraToken: agoraToken ?? this.agoraToken,
      status: status ?? this.status,
      callType: callType ?? this.callType,
      duration: duration ?? this.duration,
      billedMinutes: billedMinutes ?? this.billedMinutes,
      totalPointsDebited: totalPointsDebited ?? this.totalPointsDebited,
      ratePerMinute: ratePerMinute ?? this.ratePerMinute,
      endReason: endReason ?? this.endReason,
      hostId: hostId ?? this.hostId,
      callerId: callerId ?? this.callerId,
    );
  }

  @override
  List<Object?> get props => [
        callId,
        agoraChannel,
        agoraToken,
        status,
        callType,
        duration,
        billedMinutes,
        totalPointsDebited,
        ratePerMinute,
        endReason,
        hostId,
        callerId,
      ];
}
