import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class OtpHeader extends StatelessWidget {
  const OtpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.verifyYourNumber,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              AppTexts.sentCodeToNumber,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '+91 9876543210',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
