import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class ProfileWarning extends StatelessWidget {
  const ProfileWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: AppColors.red, size: 16.sp),
        SizedBox(width: 6.w),
        Text(
          AppTexts.wrongGenderBan,
          style: GoogleFonts.manrope(
            fontSize: 12.sp,
            color: AppColors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
