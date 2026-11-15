import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

/// "A little hello goes a long way" flanked by coral accent dashes.
class WelcomeTagline extends StatelessWidget {
  const WelcomeTagline({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _AccentDashes(),
        SizedBox(width: 10.w),
        Flexible(
          child: Text(
            AppTexts.welcomeTagline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.plumMuted,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        const _AccentDashes(mirrored: true),
      ],
    );
  }
}

/// Two short strokes fanning away from the text, like a little "hey!".
class _AccentDashes extends StatelessWidget {
  final bool mirrored;

  const _AccentDashes({this.mirrored = false});

  @override
  Widget build(BuildContext context) {
    final angle = (mirrored ? -1 : 1) * math.pi / 7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dash(angle),
        SizedBox(height: 5.h),
        _dash(-angle),
      ],
    );
  }

  Widget _dash(double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 10.w,
        height: 2.5.h,
        decoration: BoxDecoration(
          color: AppColors.audioAccent,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
