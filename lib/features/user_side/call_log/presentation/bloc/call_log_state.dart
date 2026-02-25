part of 'call_log_cubit.dart';

@immutable
abstract class CallLogState {}

class CallLogInitial extends CallLogState {}

class CallLogLoaded extends CallLogState {
  final List<CallLogEntry> callLogs;

  CallLogLoaded(this.callLogs);
}

class CallLogEntry {
  final String name;
  final String imageUrl;
  final String time;
  final CallType type;
  final bool isVideoCall;
  final String? duration;

  CallLogEntry({
    required this.name,
    required this.imageUrl,
    required this.time,
    required this.type,
    required this.isVideoCall,
    this.duration,
  });
}
