import '../../domain/entities/host_target_entity.dart';

class HostTargetDto extends HostTargetEntity {
  const HostTargetDto({
    required super.id,
    required super.hostId,
    required super.period,
    super.callTypeFilter,
    required super.startDate,
    required super.endDate,
    required super.targetType,
    required super.targetValue,
    required super.currentValue,
    required super.status,
  });

  factory HostTargetDto.fromJson(Map<String, dynamic> json) {
    return HostTargetDto(
      id: json['_id'] as String? ?? '',
      hostId: json['hostId'] as String? ?? '',
      period: json['period'] as String? ?? '',
      callTypeFilter: json['callTypeFilter'] as String? ?? 'all',
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      targetType: json['targetType'] as String? ?? '',
      targetValue: json['targetValue'] as num? ?? 0,
      currentValue: json['currentValue'] as num? ?? 0,
      status: json['status'] as String? ?? 'in_progress',
    );
  }
}
