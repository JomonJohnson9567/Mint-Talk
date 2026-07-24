import 'package:equatable/equatable.dart';

class CallReportEntity extends Equatable {
  final String id;
  final String reporterId;
  final String reportedId;
  final String callId;
  final String reason;
  final String description;
  final DateTime? createdAt;

  const CallReportEntity({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.callId,
    required this.reason,
    required this.description,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        reporterId,
        reportedId,
        callId,
        reason,
        description,
        createdAt,
      ];
}
