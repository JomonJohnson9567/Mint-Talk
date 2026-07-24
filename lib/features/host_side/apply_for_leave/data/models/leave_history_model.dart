import '../../domain/entities/leave_history_entity.dart';

class LeaveHistoryItemModel extends LeaveHistoryItemEntity {
  const LeaveHistoryItemModel({
    required super.id,
    required super.startDate,
    required super.endDate,
    required super.reason,
    required super.status,
    required super.createdAt,
  });

  factory LeaveHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return LeaveHistoryItemModel(
      id: json['_id'] as String? ?? '',
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class LeaveHistoryPageModel extends LeaveHistoryPageEntity {
  const LeaveHistoryPageModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.leaves,
  });

  factory LeaveHistoryPageModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? const {});
    final leaves = (data['leaves'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LeaveHistoryItemModel.fromJson)
        .toList();

    return LeaveHistoryPageModel(
      total: data['total'] as int? ?? leaves.length,
      page: data['page'] as int? ?? 1,
      limit: data['limit'] as int? ?? leaves.length,
      leaves: leaves,
    );
  }
}
