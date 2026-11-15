import '../../domain/entities/call_statistics_report_entity.dart';

class CallStatisticsDto {
  final String role;
  final int totalCalls;
  final num totalDurationMinutes;
  final num totalBilledUnits;
  final num totalPointsSpentOrEarned;

  const CallStatisticsDto({
    required this.role,
    required this.totalCalls,
    required this.totalDurationMinutes,
    required this.totalBilledUnits,
    required this.totalPointsSpentOrEarned,
  });

  factory CallStatisticsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return CallStatisticsDto(
      role: (data['role'] ?? '').toString(),
      totalCalls: data['totalCalls'] is int ? data['totalCalls'] : 0,
      totalDurationMinutes: data['totalDurationMinutes'] is num
          ? data['totalDurationMinutes']
          : 0,
      totalBilledUnits:
          (data['totalBilledUnits'] ?? data['totalBilledMinutes']) is num
          ? (data['totalBilledUnits'] ?? data['totalBilledMinutes'])
          : 0,
      totalPointsSpentOrEarned: data['totalPointsSpentOrEarned'] is num
          ? data['totalPointsSpentOrEarned']
          : 0,
    );
  }

  CallStatisticsReportEntity toEntity() {
    return CallStatisticsReportEntity(
      role: role,
      totalCalls: totalCalls,
      totalDurationMinutes: totalDurationMinutes,
      totalBilledUnits: totalBilledUnits,
      totalPointsSpentOrEarned: totalPointsSpentOrEarned,
    );
  }
}
