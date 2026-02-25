// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

class SuccessSetupScreen extends StatelessWidget {
  const SuccessSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Light background color
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 16.h),

              const Spacer(),
              const _VerifiedCard(),
              const Spacer(),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedCard extends StatelessWidget {
  const _VerifiedCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.textGrey.withAlpha(102)),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SuccessIcon(),
          SizedBox(height: 20.h),
          Text(
            AppTexts.congratulations,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            AppTexts.setupVerifiedMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textGrey,
              height: 1.5,
            ),
          ),
          SizedBox(height: 32.h),
          PrimaryButton(
            text: AppTexts.continueText,
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
            },
          ),
        ],
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120.w,
      width: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative circle (light reflection effect)
          Positioned(
            top: 10.w,
            right: 15.w,
            child: Container(
              height: 12.w,
              width: 12.w,
              decoration: const BoxDecoration(
                color: Color(0xFFE0E2FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 20.w,
            left: 10.w,
            child: Container(
              height: 20.w,
              width: 20.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main Icon Circle with Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  height: 80.w,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withAlpha(102),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 40.sp,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
