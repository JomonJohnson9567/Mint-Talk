import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/agora/call_audio_route.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/call_audio_route_display.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_action_button.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_glass_card.dart';

/// Frosted bottom card with labelled Mute / audio-route toggles above a
/// coral end-call button.
class AudioCallControls extends StatelessWidget {
  final bool isMuted;
  final CallAudioRoute audioRoute;
  final bool isCallActive;
  final VoidCallback onToggleMute;
  final VoidCallback onAudioRouteTap;
  final VoidCallback onEndCall;

  const AudioCallControls({
    super.key,
    required this.isMuted,
    required this.audioRoute,
    required this.isCallActive,
    required this.onToggleMute,
    required this.onAudioRouteTap,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return CallGlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                icon: audioRoute.icon,
                label: audioRoute.label,
                isActive: audioRoute != CallAudioRoute.earpiece,
                onTap: onAudioRouteTap,
                semanticLabel: 'Audio output: ${audioRoute.label}',
              ),
            ],
          ),
          SizedBox(height: 10.cw),
          CallEndButton(isCallActive: isCallActive, onTap: onEndCall),
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
    return CallActionButton(
      icon: icon,
      onTap: onTap,
      iconColor: isActive ? AppColors.white : AppColors.primaryColor,
      backgroundColor: isActive ? AppColors.primaryColor : AppColors.videoBtnBg,
      buttonSize: 60,
      iconSize: 26,
      label: label,
      labelStyle: TextStyle(
        fontSize: 13.csp,
        fontWeight: FontWeight.w600,
        color: AppColors.plumDeep,
      ),
      semanticLabel: semanticLabel,
    );
  }
}

/// The coral hang-up button shared by the audio and video controls —
/// "Cancel call" until the call connects, "End call" after.
class CallEndButton extends StatelessWidget {
  final bool isCallActive;
  final VoidCallback onTap;
  final Color labelColor;

  const CallEndButton({
    super.key,
    required this.isCallActive,
    required this.onTap,
    this.labelColor = AppColors.plumDeep,
  });

  @override
  Widget build(BuildContext context) {
    final label = isCallActive ? AppTexts.endCall : AppTexts.cancelCall;

    return CallActionButton(
      icon: Icons.call_end_rounded,
      onTap: onTap,
      iconColor: AppColors.white,
      backgroundColor: AppColors.audioAccent,
      buttonSize: 72,
      iconSize: 32,
      label: label,
      labelStyle: TextStyle(
        fontSize: 13.csp,
        fontWeight: FontWeight.w700,
        color: labelColor,
      ),
      semanticLabel: label,
      boxShadow: [
        BoxShadow(
          color: AppColors.audioAccent.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
