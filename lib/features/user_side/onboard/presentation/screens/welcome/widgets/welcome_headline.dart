import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class WelcomeHeadline extends StatelessWidget {
  const WelcomeHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.welcomeHeadline,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 38.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.plumDeep,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          AppTexts.welcomeSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15.sp,
            color: AppColors.plumMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
