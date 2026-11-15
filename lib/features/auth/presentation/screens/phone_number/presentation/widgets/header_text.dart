import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class HeaderText extends StatelessWidget {
  const HeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.loginHeadline,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 36.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.plumDeep,
            height: 1.05,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          AppTexts.signInToJoinTheConversation,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.plumMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
