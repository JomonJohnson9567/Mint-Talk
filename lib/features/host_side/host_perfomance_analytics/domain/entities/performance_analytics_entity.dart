import 'package:equatable/equatable.dart';

/// Represents a host's single-day call statistics in the history list.
class DailyPerformanceEntity extends Equatable {
  final String date;
  final bool isToday;
  final double videoMin;
  final double videoTarget;
  final double audioMin;
  final double audioTarget;
  final double totalMin;
  final double totalTarget;
  final bool targetMet;
  final bool trendUp;

  const DailyPerformanceEntity({
    required this.date,
    required this.isToday,
    required this.videoMin,
    required this.videoTarget,
    required this.audioMin,
    required this.audioTarget,
    required this.totalMin,
    required this.totalTarget,
    required this.targetMet,
    required this.trendUp,
  });

  @override
  List<Object?> get props => [
        date,
        isToday,
        videoMin,
        videoTarget,
        audioMin,
        audioTarget,
        totalMin,
        totalTarget,
        targetMet,
        trendUp,
      ];
}

/// Represents the top aggregate analytics and list data for the target screen.
class PerformanceAnalyticsEntity extends Equatable {
  final String todayDateLabel;
  final double todayVideoMin;
  final double todayVideoTarget;
  final double todayVideoPercentage;
  final double todayAudioMin;
  final double todayAudioTarget;
  final double todayAudioPercentage;
  final bool todayTargetMet;

  final double achievementRate;
  final int achievementDays;
  final int totalDays;

  final int totalVideoMinutes;
  final int totalAudioMinutes;

  final List<DailyPerformanceEntity> dailyHistory;

  const PerformanceAnalyticsEntity({
    required this.todayDateLabel,
    required this.todayVideoMin,
    required this.todayVideoTarget,
    required this.todayVideoPercentage,
    required this.todayAudioMin,
    required this.todayAudioTarget,
    required this.todayAudioPercentage,
    required this.todayTargetMet,
    required this.achievementRate,
    required this.achievementDays,
    required this.totalDays,
    required this.totalVideoMinutes,
    required this.totalAudioMinutes,
    required this.dailyHistory,
  });

  @override
  List<Object?> get props => [
        todayDateLabel,
        todayVideoMin,
        todayVideoTarget,
        todayVideoPercentage,
        todayAudioMin,
        todayAudioTarget,
        todayAudioPercentage,
        todayTargetMet,
        achievementRate,
        achievementDays,
        totalDays,
        totalVideoMinutes,
        totalAudioMinutes,
        dailyHistory,
      ];
}
