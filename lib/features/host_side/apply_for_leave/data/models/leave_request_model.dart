import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_request_entity.dart';

class LeaveRequestModel extends LeaveRequestEntity {
  const LeaveRequestModel({
    required super.startDate,
    required super.endDate,
    required super.reason,
    super.leaveType,
  });

  factory LeaveRequestModel.fromEntity(LeaveRequestEntity entity) {
    return LeaveRequestModel(
      startDate: entity.startDate,
      endDate: entity.endDate,
      reason: entity.reason,
      leaveType: entity.leaveType,
    );
  }

  Map<String, dynamic> toJson() {
    final startStr =
        '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr =
        '${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

    return {
      'startDate': startStr,
      'endDate': endStr,
      'reason': reason.trim(),
    };
  }
}
