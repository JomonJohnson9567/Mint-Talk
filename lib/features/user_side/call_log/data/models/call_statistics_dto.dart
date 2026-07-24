import '../../domain/entities/call_statistics_report_entity.dart';

class CallStatisticsDto {
  final String role;
  final int totalCalls;
  final num totalDurationMinutes;
  final num totalBilledMinutes;
  final num totalPointsSpentOrEarned;

  const CallStatisticsDto({
    required this.role,
    required this.totalCalls,
    required this.totalDurationMinutes,
    required this.totalBilledMinutes,
    required this.totalPointsSpentOrEarned,
  });

  factory CallStatisticsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return CallStatisticsDto(
      role: (data['role'] ?? '').toString(),
      totalCalls: data['totalCalls'] is int ? data['totalCalls'] : 0,
      totalDurationMinutes: data['totalDurationMinutes'] is num ? data['totalDurationMinutes'] : 0,
      totalBilledMinutes: data['totalBilledMinutes'] is num ? data['totalBilledMinutes'] : 0,
      totalPointsSpentOrEarned: data['totalPointsSpentOrEarned'] is num ? data['totalPointsSpentOrEarned'] : 0,
    );
  }

  CallStatisticsReportEntity toEntity() {
    return CallStatisticsReportEntity(
      role: role,
      totalCalls: totalCalls,
      totalDurationMinutes: totalDurationMinutes,
      totalBilledMinutes: totalBilledMinutes,
      totalPointsSpentOrEarned: totalPointsSpentOrEarned,
    );
  }
}
