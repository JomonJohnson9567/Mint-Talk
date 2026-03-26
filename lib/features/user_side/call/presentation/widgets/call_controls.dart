import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_action_button.dart';
import '../../../../../core/theme/color.dart';

class CallControls extends StatelessWidget {
  final VoidCallback onEndCall;

  const CallControls({super.key, required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    final actionButtonSize = 50.w;
    final callButtonSize = 72.w;
    final preferredGap = 12.w;
    final totalButtonWidth = (actionButtonSize * 4) + callButtonSize;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 40.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonGap = ((constraints.maxWidth - totalButtonWidth) / 4)
              .clamp(0.0, preferredGap)
              .toDouble();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.cameraswitch_outlined,
                onTap: () {},
              ),
              SizedBox(width: buttonGap),
              _buildActionButton(icon: Icons.videocam_outlined, onTap: () {}),
              SizedBox(width: buttonGap),
              _buildCallButton(onTap: onEndCall),
              SizedBox(width: buttonGap),
              _buildActionButton(icon: Icons.mic_off_outlined, onTap: () {}),
              SizedBox(width: buttonGap),
              _buildActionButton(icon: Icons.more_horiz, onTap: () {}),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CallActionButton(
      icon: icon,
      onTap: onTap,
      iconColor: AppColors.black.withAlpha(179),
      backgroundColor: AppColors.white.withAlpha(128),
      buttonSize: 50,
      iconSize: 24,
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
