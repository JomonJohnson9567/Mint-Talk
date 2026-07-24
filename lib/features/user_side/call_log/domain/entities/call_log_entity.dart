import 'package:equatable/equatable.dart';
import 'call_participant_entity.dart';

class CallLogEntity extends Equatable {
  final String id;
  final CallParticipantEntity? caller;
  final CallParticipantEntity? host;
  final String status;
  final String callType;
  final int duration;
  final int billedMinutes;
  final num totalPointsDebited;
  final String endReason;
  final DateTime? createdAt;

  const CallLogEntity({
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

  @override
  List<Object?> get props => [
        id,
        caller,
        host,
        status,
        callType,
        duration,
        billedMinutes,
        totalPointsDebited,
        endReason,
        createdAt,
      ];
}
