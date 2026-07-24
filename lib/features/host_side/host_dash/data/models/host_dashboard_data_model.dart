import '../../domain/entities/host_dashboard_data_entity.dart';

class HostDashboardDataModel extends HostDashboardDataEntity {
  const HostDashboardDataModel({
    required super.hostName,
    required super.avatarAsset,
    required super.dailyMinCoveredVideo,
    required super.dailyMinCoveredAudio,
    required super.totalMinCoveredVideo,
    required super.totalMinCoveredAudio,
    required super.videoTargetHours,
    required super.videoTargetMaxHours,
    required super.audioTargetHours,
    required super.audioTargetMaxHours,
  });

  factory HostDashboardDataModel.fromJson(Map<String, dynamic> json) {
    return HostDashboardDataModel(
      hostName: json['host_name'] ?? '',
      avatarAsset: json['avatar_asset'] ?? '',
      dailyMinCoveredVideo: (json['daily_min_covered_video'] as num?)?.toDouble() ?? 0.0,
      dailyMinCoveredAudio: (json['daily_min_covered_audio'] as num?)?.toDouble() ?? 0.0,
      totalMinCoveredVideo: (json['total_min_covered_video'] as num?)?.toDouble() ?? 0.0,
      totalMinCoveredAudio: (json['total_min_covered_audio'] as num?)?.toDouble() ?? 0.0,
      videoTargetHours: (json['video_target_hours'] as num?)?.toDouble() ?? 0.0,
      videoTargetMaxHours: (json['video_target_max_hours'] as num?)?.toDouble() ?? 0.0,
      audioTargetHours: (json['audio_target_hours'] as num?)?.toDouble() ?? 0.0,
      audioTargetMaxHours: (json['audio_target_max_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host_name': hostName,
      'avatar_asset': avatarAsset,
      'daily_min_covered_video': dailyMinCoveredVideo,
      'daily_min_covered_audio': dailyMinCoveredAudio,
      'total_min_covered_video': totalMinCoveredVideo,
      'total_min_covered_audio': totalMinCoveredAudio,
      'video_target_hours': videoTargetHours,
      'video_target_max_hours': videoTargetMaxHours,
      'audio_target_hours': audioTargetHours,
      'audio_target_max_hours': audioTargetMaxHours,
    };
  }
}
