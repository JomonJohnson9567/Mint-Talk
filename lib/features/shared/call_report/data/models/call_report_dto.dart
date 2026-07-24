import '../../domain/entities/call_report_entity.dart';

class CallReportDto {
  final String id;
  final String reporterId;
  final String reportedId;
  final String callId;
  final String reason;
  final String description;
  final DateTime? createdAt;

  const CallReportDto({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.callId,
    required this.reason,
    required this.description,
    this.createdAt,
  });

  factory CallReportDto.fromJson(Map<String, dynamic> json) {
    return CallReportDto(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      reporterId: (json['reporterId'] ?? '').toString(),
      reportedId: (json['reportedId'] ?? '').toString(),
      callId: (json['callId'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }

  CallReportEntity toEntity() {
    return CallReportEntity(
      id: id,
      reporterId: reporterId,
      reportedId: reportedId,
      callId: callId,
      reason: reason,
      description: description,
      createdAt: createdAt,
    );
  }
}
