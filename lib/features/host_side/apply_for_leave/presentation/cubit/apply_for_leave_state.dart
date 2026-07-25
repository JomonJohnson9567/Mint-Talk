import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_history_entity.dart';

enum ApplyForLeaveStatus { initial, loading, success, failure }
enum LeaveHistoryStatus { initial, loading, loaded, failure }

class ApplyForLeaveState extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String reason;
  final String leaveType;
  final int availableDays;
  final ApplyForLeaveStatus status;
  final LeaveHistoryStatus historyStatus;
  final List<LeaveHistoryItemEntity> history;
  final int historyPage;
  final int historyTotal;
  final String? errorMessage;

  const ApplyForLeaveState({
    this.startDate,
    this.endDate,
    this.reason = '',
    this.leaveType = 'Casual Leave',
    this.availableDays = 12,
    this.status = ApplyForLeaveStatus.initial,
    this.historyStatus = LeaveHistoryStatus.initial,
    this.history = const [],
    this.historyPage = 1,
    this.historyTotal = 0,
    this.errorMessage,
  });

  ApplyForLeaveState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? reason,
    String? leaveType,
    int? availableDays,
    ApplyForLeaveStatus? status,
    LeaveHistoryStatus? historyStatus,
    List<LeaveHistoryItemEntity>? history,
    int? historyPage,
    int? historyTotal,
    String? errorMessage,
  }) {
    return ApplyForLeaveState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
      leaveType: leaveType ?? this.leaveType,
      availableDays: availableDays ?? this.availableDays,
      status: status ?? this.status,
      historyStatus: historyStatus ?? this.historyStatus,
      history: history ?? this.history,
      historyPage: historyPage ?? this.historyPage,
      historyTotal: historyTotal ?? this.historyTotal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        reason,
        leaveType,
        availableDays,
        status,
        historyStatus,
        history,
        historyPage,
        historyTotal,
        errorMessage,
      ];
}
