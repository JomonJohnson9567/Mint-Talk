import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/domain/entities/host_call_log_entry_entity.dart';

abstract class HostCallLogState extends Equatable {
  const HostCallLogState();

  @override
  List<Object?> get props => [];
}

class HostCallLogInitial extends HostCallLogState {
  const HostCallLogInitial();
}

class HostCallLogLoading extends HostCallLogState {
  const HostCallLogLoading();
}

class HostCallLogLoaded extends HostCallLogState {
  final List<HostCallLogEntryEntity> entries;

  const HostCallLogLoaded({required this.entries});

  @override
  List<Object?> get props => [entries];
}
