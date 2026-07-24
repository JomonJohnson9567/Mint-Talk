import 'package:equatable/equatable.dart';

class CallStatisticsReportEntity extends Equatable {
  final String role;
  final int totalCalls;
  final num totalDurationMinutes;
  final num totalBilledMinutes;
  final num totalPointsSpentOrEarned;

  const CallStatisticsReportEntity({
    required this.role,
    required this.totalCalls,
    required this.totalDurationMinutes,
    required this.totalBilledMinutes,
    required this.totalPointsSpentOrEarned,
  });

  @override
  List<Object?> get props => [
        role,
        totalCalls,
        totalDurationMinutes,
        totalBilledMinutes,
        totalPointsSpentOrEarned,
      ];
}
