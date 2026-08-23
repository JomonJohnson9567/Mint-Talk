import '../../domain/entities/performance_analytics_entity.dart';

class DailyPerformanceModel extends DailyPerformanceEntity {
  const DailyPerformanceModel({
    required super.date,
    required super.isToday,
    required super.videoMin,
    required super.videoTarget,
    required super.audioMin,
    required super.audioTarget,
    required super.totalMin,
    required super.totalTarget,
    required super.targetMet,
    required super.trendUp,
  });

  factory DailyPerformanceModel.fromJson(Map<String, dynamic> json) {
    return DailyPerformanceModel(
      date: json['date'] as String? ?? '',
      isToday: json['isToday'] as bool? ?? false,
      videoMin: (json['videoMin'] as num? ?? 0.0).toDouble(),
      videoTarget: (json['videoTarget'] as num? ?? 0.0).toDouble(),
      audioMin: (json['audioMin'] as num? ?? 0.0).toDouble(),
      audioTarget: (json['audioTarget'] as num? ?? 0.0).toDouble(),
      totalMin: (json['totalMin'] as num? ?? 0.0).toDouble(),
      totalTarget: (json['totalTarget'] as num? ?? 0.0).toDouble(),
      targetMet: json['targetMet'] as bool? ?? false,
      trendUp: json['trendUp'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'isToday': isToday,
      'videoMin': videoMin,
      'videoTarget': videoTarget,
      'audioMin': audioMin,
      'audioTarget': audioTarget,
      'totalMin': totalMin,
      'totalTarget': totalTarget,
      'targetMet': targetMet,
      'trendUp': trendUp,
    };
  }
}

class PerformanceAnalyticsModel extends PerformanceAnalyticsEntity {
  const PerformanceAnalyticsModel({
    required super.todayDateLabel,
    required super.todayVideoMin,
    required super.todayVideoTarget,
    required super.todayVideoPercentage,
    required super.todayAudioMin,
    required super.todayAudioTarget,
    required super.todayAudioPercentage,
    required super.todayTargetMet,
    required super.achievementRate,
    required super.achievementDays,
    required super.totalDays,
    required super.totalVideoMinutes,
    required super.totalAudioMinutes,
    required List<DailyPerformanceModel> super.dailyHistory,
  });

  factory PerformanceAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final historyList = (json['dailyHistory'] as List? ?? [])
        .map((e) => DailyPerformanceModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PerformanceAnalyticsModel(
      todayDateLabel: json['todayDateLabel'] as String? ?? '',
      todayVideoMin: (json['todayVideoMin'] as num? ?? 0.0).toDouble(),
      todayVideoTarget: (json['todayVideoTarget'] as num? ?? 0.0).toDouble(),
      todayVideoPercentage: (json['todayVideoPercentage'] as num? ?? 0.0).toDouble(),
      todayAudioMin: (json['todayAudioMin'] as num? ?? 0.0).toDouble(),
      todayAudioTarget: (json['todayAudioTarget'] as num? ?? 0.0).toDouble(),
      todayAudioPercentage: (json['todayAudioPercentage'] as num? ?? 0.0).toDouble(),
      todayTargetMet: json['todayTargetMet'] as bool? ?? false,
      achievementRate: (json['achievementRate'] as num? ?? 0.0).toDouble(),
      achievementDays: (json['achievementDays'] as num?)?.toInt() ?? 0,
      totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
      totalVideoMinutes: (json['totalVideoMinutes'] as num?)?.toInt() ?? 0,
      totalAudioMinutes: (json['totalAudioMinutes'] as num?)?.toInt() ?? 0,
      dailyHistory: historyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayDateLabel': todayDateLabel,
      'todayVideoMin': todayVideoMin,
      'todayVideoTarget': todayVideoTarget,
      'todayVideoPercentage': todayVideoPercentage,
      'todayAudioMin': todayAudioMin,
      'todayAudioTarget': todayAudioTarget,
      'todayAudioPercentage': todayAudioPercentage,
      'todayTargetMet': todayTargetMet,
      'achievementRate': achievementRate,
      'achievementDays': achievementDays,
      'totalDays': totalDays,
      'totalVideoMinutes': totalVideoMinutes,
      'totalAudioMinutes': totalAudioMinutes,
      'dailyHistory': dailyHistory.map((e) => (e as DailyPerformanceModel).toJson()).toList(),
    };
  }
}
