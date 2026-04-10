import 'package:mint_talk/core/constants/app_assets.dart';

class VideoCallOnlineUser {
  final String name;
  final String imagePath;
  final String focusArea;
  final double rating;
  final int ratePerMinute;
  final int responseMinutes;
  final bool isVerified;

  const VideoCallOnlineUser({
    required this.name,
    required this.imagePath,
    required this.focusArea,
    required this.rating,
    required this.ratePerMinute,
    required this.responseMinutes,
    this.isVerified = true,
  });

  static const List<VideoCallOnlineUser> sampleUsers = [
    VideoCallOnlineUser(
      name: 'Ananya',
      imagePath: AppAssets.femaleIcon,
      focusArea: 'Emotional support and active listening',
      rating: 4.9,
      ratePerMinute: 1500,
      responseMinutes: 2,
    ),
    VideoCallOnlineUser(
      name: 'Rahul',
      imagePath: AppAssets.maleIcon,
      focusArea: 'Motivation and life direction',
      rating: 4.8,
      ratePerMinute: 1400,
      responseMinutes: 3,
    ),
    VideoCallOnlineUser(
      name: 'Meera',
      imagePath: AppAssets.femaleIcon,
      focusArea: 'Stress management and calm conversations',
      rating: 5.0,
      ratePerMinute: 1600,
      responseMinutes: 1,
    ),
    VideoCallOnlineUser(
      name: 'Arjun',
      imagePath: AppAssets.maleIcon,
      focusArea: 'Confidence building and resilience',
      rating: 4.7,
      ratePerMinute: 1300,
      responseMinutes: 4,
    ),
  ];
}
