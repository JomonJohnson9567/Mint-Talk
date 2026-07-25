import 'package:equatable/equatable.dart';

class LeaveRequestEntity extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String leaveType;

  const LeaveRequestEntity({
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.leaveType = 'Casual Leave',
  });

  @override
  List<Object?> get props => [startDate, endDate, reason, leaveType];
}
