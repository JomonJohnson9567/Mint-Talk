import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/video_call_online_contents.dart';

class VideoCallOnlineScreen extends StatelessWidget {
  const VideoCallOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: VideoCallOnlineContents(),
    );
  }
}
