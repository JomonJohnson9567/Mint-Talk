import 'package:equatable/equatable.dart';
import 'call_type.dart';

class CallSessionEntity extends Equatable {
  final String callId;
  final String? agoraChannel;
  final String? agoraToken;
  final String
  status; // ringing | accepted | active | ended | failed | rejected | missed | insufficient_balance
  final CallType callType;
  final int duration;
  final int billedUnits;
  final int totalPointsDebited;
  final int ratePerMinute;
  final String endReason;
  final String hostId;
  final String callerId;

  /// Agora UID assigned to the local participant, when the server sends one.
  /// Falls back to [CallParticipantRole.agoraUid] (caller 1, host 2).
  final int? agoraUid;

  /// How long the participants have to activate after acceptance before
  /// the server fails the call as `connection_timeout`. Null → 60s.
  final int? connectionTimeoutSeconds;

  /// Lifetime of [agoraToken], used to schedule renewal.
  final int? tokenExpiresInSeconds;

  /// Server time billing started — the in-call timer counts from this.
  final DateTime? activeAt;

  /// Server time the ringing window closes (audio and video alike). Both
  /// ring timers count down to this via `ServerClock`; null → 20 s fallback.
  final DateTime? ringExpiresAt;

  const CallSessionEntity({
    required this.callId,
    this.agoraChannel,
    this.agoraToken,
    required this.status,
    required this.callType,
    required this.duration,
    required this.billedUnits,
    required this.totalPointsDebited,
    required this.ratePerMinute,
    required this.endReason,
    required this.hostId,
    required this.callerId,
    this.agoraUid,
    this.connectionTimeoutSeconds,
    this.tokenExpiresInSeconds,
    this.activeAt,
    this.ringExpiresAt,
  });

  CallSessionEntity copyWith({
    String? callId,
    String? agoraChannel,
    String? agoraToken,
    String? status,
    CallType? callType,
    int? duration,
    int? billedUnits,
    int? totalPointsDebited,
    int? ratePerMinute,
    String? endReason,
    String? hostId,
    String? callerId,
    int? agoraUid,
    int? connectionTimeoutSeconds,
    int? tokenExpiresInSeconds,
    DateTime? activeAt,
    DateTime? ringExpiresAt,
  }) {
    return CallSessionEntity(
      callId: callId ?? this.callId,
      agoraChannel: agoraChannel ?? this.agoraChannel,
      agoraToken: agoraToken ?? this.agoraToken,
      status: status ?? this.status,
      callType: callType ?? this.callType,
      duration: duration ?? this.duration,
      billedUnits: billedUnits ?? this.billedUnits,
      totalPointsDebited: totalPointsDebited ?? this.totalPointsDebited,
      ratePerMinute: ratePerMinute ?? this.ratePerMinute,
      endReason: endReason ?? this.endReason,
      hostId: hostId ?? this.hostId,
      callerId: callerId ?? this.callerId,
      agoraUid: agoraUid ?? this.agoraUid,
      connectionTimeoutSeconds:
          connectionTimeoutSeconds ?? this.connectionTimeoutSeconds,
      tokenExpiresInSeconds:
          tokenExpiresInSeconds ?? this.tokenExpiresInSeconds,
      activeAt: activeAt ?? this.activeAt,
      ringExpiresAt: ringExpiresAt ?? this.ringExpiresAt,
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
    billedUnits,
    totalPointsDebited,
    ratePerMinute,
    endReason,
    hostId,
    callerId,
    agoraUid,
    connectionTimeoutSeconds,
    tokenExpiresInSeconds,
    activeAt,
    ringExpiresAt,
  ];
}
