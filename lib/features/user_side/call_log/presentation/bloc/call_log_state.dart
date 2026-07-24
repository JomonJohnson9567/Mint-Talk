import 'package:equatable/equatable.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/call_log/domain/entities/call_log_entity.dart';

enum CallType { missed, outgoing }

class CallLogEntry extends Equatable {
  final String name;
  final String imageUrl;
  final String time;
  final CallType type;
  final bool isVideoCall;
  final String? duration;
  final String? callId;

  const CallLogEntry({
    required this.name,
    required this.imageUrl,
    required this.time,
    required this.type,
    required this.isVideoCall,
    this.duration,
    this.callId,
  });

  factory CallLogEntry.fromCallLogEntity(CallLogEntity entity) {
    final name = entity.host?.fullName.isNotEmpty == true
        ? entity.host!.fullName
        : (entity.caller?.fullName.isNotEmpty == true ? entity.caller!.fullName : 'Call Participant');
    final imageUrl = entity.host?.avatarUrl.isNotEmpty == true
        ? entity.host!.avatarUrl
        : (entity.caller?.avatarUrl ?? '');
    
    CallType type = CallType.outgoing;
    if (entity.status == 'missed' || entity.status == 'rejected') {
      type = CallType.missed;
    }

    final durationStr = entity.duration > 0
        ? '${entity.duration ~/ 60}m ${entity.duration % 60}s'
        : null;

    return CallLogEntry(
      name: name,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : AppAssets.femaleIcon,
      time: entity.createdAt != null
          ? '${entity.createdAt!.day}/${entity.createdAt!.month} ${entity.createdAt!.hour}:${entity.createdAt!.minute.toString().padLeft(2, '0')}'
          : 'Recent',
      type: type,
      isVideoCall: entity.callType == 'video',
      duration: durationStr,
      callId: entity.id,
    );
  }

  @override
  List<Object?> get props => [name, imageUrl, time, type, isVideoCall, duration, callId];
}

sealed class CallLogState extends Equatable {
  const CallLogState();

  @override
  List<Object?> get props => [];
}

class CallLogInitial extends CallLogState {
  const CallLogInitial();
}

class CallLogLoading extends CallLogState {
  const CallLogLoading();
}

class CallLogLoaded extends CallLogState {
  final List<CallLogEntry> callLogs;

  const CallLogLoaded(this.callLogs);

  @override
  List<Object?> get props => [callLogs];
}

class CallLogError extends CallLogState {
  final String message;

  const CallLogError(this.message);

  @override
  List<Object?> get props => [message];
}
