import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor.withValues(alpha: 0.06),
              AppColors.primaryColor.withValues(alpha: 0.04),
              AppColors.primaryColor.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.15),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            // Diamond Icon Badge
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
              ),
            child: Icon(
              Icons.diamond_rounded,
              color: AppColors.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // Banner text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stay Active, Earn More!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'More calls, more minutes, more rewards.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Gift Box Illustration
          _buildGiftBoxIllustration(),
        ],
      ),
    );
  }

  Widget _buildGiftBoxIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative background particles
        Container(
          width: 50.w,
          height: 50.h,
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 4.h,
                left: 6.w,
                child: Container(
                  width: 5.w,
                  height: 5.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A52DA),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 8.h,
                right: 4.w,
                child: Container(
                  width: 6.w,
                  height: 6.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC857),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  width: 4.w,
                  height: 4.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF18A957),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Gift box body container representation
        Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.card_giftcard_rounded,
            color: AppColors.primaryColor,
            size: 26.sp,
          ),
        ),
      ],
    );
  }
}
