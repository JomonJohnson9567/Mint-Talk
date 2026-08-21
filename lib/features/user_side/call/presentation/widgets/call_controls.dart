import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_action_button.dart';
import '../../../../../core/theme/color.dart';

class CallControls extends StatelessWidget {
  final VoidCallback onEndCall;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onSwitchCamera;
  final bool isMuted;
  final bool isVideoMuted;
  final bool isSpeakerOn;
  final bool isVideoCall;

  const CallControls({
    super.key,
    required this.onEndCall,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onToggleSpeaker,
    required this.onSwitchCamera,
    this.isMuted = false,
    this.isVideoMuted = false,
    this.isSpeakerOn = false,
    this.isVideoCall = false,
  });

  @override
  Widget build(BuildContext context) {
    final actionButtonCount = isVideoCall ? 4 : 2;
    final actionButtonSize = 50.w;
    final callButtonSize = 72.w;
    final preferredGap = 12.w;
    final totalButtonWidth = (actionButtonSize * actionButtonCount) + callButtonSize;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonGap = ((constraints.maxWidth - totalButtonWidth) / (actionButtonCount + 1))
              .clamp(0.0, preferredGap)
              .toDouble();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mute Mic
              _buildActionButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                isActive: isMuted,
                onTap: onToggleMute,
                semanticLabel: isMuted ? 'Unmute microphone' : 'Mute microphone',
              ),
              SizedBox(width: buttonGap),

              // Speaker
              _buildActionButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                isActive: isSpeakerOn,
                onTap: onToggleSpeaker,
                semanticLabel: isSpeakerOn ? 'Turn speaker off' : 'Turn speaker on',
              ),
              SizedBox(width: buttonGap),

              // End Call Button
              _buildCallButton(onTap: onEndCall),

              // Video-only Controls (Mute Video & Switch Camera)
              if (isVideoCall) ...[
                SizedBox(width: buttonGap),
                _buildActionButton(
                  icon: isVideoMuted ? Icons.videocam_off : Icons.videocam,
                  isActive: isVideoMuted,
                  onTap: onToggleVideo,
                  semanticLabel: isVideoMuted ? 'Turn camera on' : 'Turn camera off',
                ),
                SizedBox(width: buttonGap),
                _buildActionButton(
                  icon: Icons.cameraswitch_outlined,
                  onTap: onSwitchCamera,
                  semanticLabel: 'Switch camera',
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    String? semanticLabel,
  }) {
    return CallActionButton(
      icon: icon,
      onTap: onTap,
      iconColor: isActive ? AppColors.white : AppColors.black.withAlpha(179),
      backgroundColor: isActive
          ? AppColors.primaryColor
          : AppColors.white.withAlpha(180),
      buttonSize: 50,
      iconSize: 24,
      semanticLabel: semanticLabel,
    );
  }

  Widget _buildCallButton({required VoidCallback onTap}) {
    return CallActionButton(
      icon: Icons.call_end,
      onTap: onTap,
      iconColor: AppColors.white,
      backgroundColor: AppColors.red,
      buttonSize: 72,
      iconSize: 32,
      semanticLabel: 'End call',
      boxShadow: [
        BoxShadow(
          color: AppColors.red.withAlpha(102),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
