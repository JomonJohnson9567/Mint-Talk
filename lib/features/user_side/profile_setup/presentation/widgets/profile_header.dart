import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.setupProfile,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.plumDeep,
            height: 1.1,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          AppTexts.fillDetails,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.plumMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
