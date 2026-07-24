import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class ReferralStatusEmptyState extends StatelessWidget {
  const ReferralStatusEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(22.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76.w,
                height: 76.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.primaryColor,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                AppTexts.noReferralRewardsYet,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Share your referral code with friends to start earning points. Your referral rewards will appear here once the backend returns data.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: AppColors.subtitleText,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code is not available yet.'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.share_rounded),
                  label: Text(AppTexts.shareReferralCode),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                },
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
