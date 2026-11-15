import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/agora/call_audio_route.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/call_audio_route_display.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_action_button.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_glass_card.dart';

/// Dark glass card over the video feed: labelled Mute / Camera /
/// audio-route toggles above the coral end-call button.
class VideoCallControls extends StatelessWidget {
  final bool isMuted;
  final bool isVideoMuted;
  final CallAudioRoute audioRoute;
  final bool isCallActive;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;
  final VoidCallback onAudioRouteTap;
  final VoidCallback onEndCall;

  const VideoCallControls({
    super.key,
    required this.isMuted,
    required this.isVideoMuted,
    required this.audioRoute,
    required this.isCallActive,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onAudioRouteTap,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return CallGlassCard(
      dark: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildToggle(
                icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: isMuted ? AppTexts.unmute : AppTexts.mute,
                isActive: isMuted,
                onTap: onToggleMute,
                semanticLabel: isMuted
                    ? 'Unmute microphone'
                    : 'Mute microphone',
              ),
              _buildToggle(
                icon: isVideoMuted
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                label: isVideoMuted ? AppTexts.cameraOff : AppTexts.camera,
                isActive: isVideoMuted,
                onTap: onToggleVideo,
                semanticLabel: isVideoMuted
                    ? 'Turn camera on'
                    : 'Turn camera off',
              ),
              _buildToggle(
                icon: audioRoute.icon,
                label: audioRoute.label,
                isActive: audioRoute != CallAudioRoute.earpiece,
                onTap: onAudioRouteTap,
                semanticLabel: 'Audio output: ${audioRoute.label}',
              ),
            ],
          ),
          SizedBox(height: 12.cw),
          CallEndButton(
            isCallActive: isCallActive,
            onTap: onEndCall,
            labelColor: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required String semanticLabel,
  }) {
    return Expanded(
      child: CallActionButton(
        icon: icon,
        onTap: onTap,
        iconColor: isActive ? AppColors.primaryColor : AppColors.white,
        backgroundColor: isActive
            ? AppColors.white.withValues(alpha: 0.95)
            : AppColors.white.withValues(alpha: 0.16),
        buttonSize: 56,
        iconSize: 24,
        label: label,
        labelStyle: TextStyle(
          fontSize: 12.csp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        semanticLabel: semanticLabel,
      ),
    );
  }
}
