import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostWarningBanner extends StatelessWidget {
  const HostWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color:
            AppColors.warningBackground, // Light yellow background for warning
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.amber.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.orange,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                AppTexts.warning,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            AppTexts.warningMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.black,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
