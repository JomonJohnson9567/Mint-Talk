import 'package:equatable/equatable.dart';

class LeaveHistoryItemEntity extends Equatable {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final DateTime createdAt;

  const LeaveHistoryItemEntity({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';

  @override
  List<Object?> get props => [id, startDate, endDate, reason, status, createdAt];
}

class LeaveHistoryPageEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final List<LeaveHistoryItemEntity> leaves;

  const LeaveHistoryPageEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.leaves,
  });

  @override
  List<Object?> get props => [total, page, limit, leaves];
}
