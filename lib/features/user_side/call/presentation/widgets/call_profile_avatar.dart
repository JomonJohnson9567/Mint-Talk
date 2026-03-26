import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/widgets/animated_breathing_glow.dart';

class CallProfileAvatar extends StatelessWidget {
  final String imagePath;
  final bool isBreathingExpanded;

  const CallProfileAvatar({
    super.key,
    required this.imagePath,
    required this.isBreathingExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBreathingGlow(
      isExpanded: isBreathingExpanded,
      glowColor: AppColors.callBreathingGlow,
      secondaryGlowColor: AppColors.callBreathingGlowSoft,
      collapsedSize: 150.w,
      expandedSize: 184.w,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.55),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 60.r,
          backgroundImage: AssetImage(imagePath),
          backgroundColor: AppColors.lightGrey,
        ),
      ),
    );
  }
}
