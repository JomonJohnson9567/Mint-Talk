import 'package:equatable/equatable.dart';

class HostDashboardDataEntity extends Equatable {
  final String hostName;
  final String avatarAsset;
  final double dailyMinCoveredVideo;
  final double dailyMinCoveredAudio;
  final double totalMinCoveredVideo;
  final double totalMinCoveredAudio;
  final double videoTargetHours;
  final double videoTargetMaxHours;
  final double audioTargetHours;
  final double audioTargetMaxHours;

  const HostDashboardDataEntity({
    required this.hostName,
    required this.avatarAsset,
    required this.dailyMinCoveredVideo,
    required this.dailyMinCoveredAudio,
    required this.totalMinCoveredVideo,
    required this.totalMinCoveredAudio,
    required this.videoTargetHours,
    required this.videoTargetMaxHours,
    required this.audioTargetHours,
    required this.audioTargetMaxHours,
  });

  @override
  List<Object?> get props => [
        hostName,
        avatarAsset,
        dailyMinCoveredVideo,
        dailyMinCoveredAudio,
        totalMinCoveredVideo,
        totalMinCoveredAudio,
        videoTargetHours,
        videoTargetMaxHours,
        audioTargetHours,
        audioTargetMaxHours,
      ];
}
