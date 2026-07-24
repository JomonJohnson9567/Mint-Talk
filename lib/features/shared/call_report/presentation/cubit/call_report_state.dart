import 'package:equatable/equatable.dart';
import '../../domain/entities/call_report_entity.dart';

sealed class CallReportState extends Equatable {
  const CallReportState();

  @override
  List<Object?> get props => [];
}

class CallReportInitial extends CallReportState {
  const CallReportInitial();
}

class CallReportSubmitting extends CallReportState {
  const CallReportSubmitting();
}

class CallReportSuccess extends CallReportState {
  final CallReportEntity report;

  const CallReportSuccess({required this.report});

  @override
  List<Object?> get props => [report];
}

class CallReportFailure extends CallReportState {
  final String message;

  const CallReportFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
