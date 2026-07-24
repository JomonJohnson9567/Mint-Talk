import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_request_entity.dart';

class LeaveRequestModel extends LeaveRequestEntity {
  const LeaveRequestModel({
    required super.startDate,
    required super.endDate,
    required super.reason,
  });

  factory LeaveRequestModel.fromEntity(LeaveRequestEntity entity) {
    return LeaveRequestModel(
      startDate: entity.startDate,
      endDate: entity.endDate,
      reason: entity.reason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
    };
  }
}
