// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class TodaysEarningCard extends StatelessWidget {
  final String todayEarning;

  const TodaysEarningCard({
    super.key,
    required this.todayEarning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.onlineIndicator.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _EarningIconCircle(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EarningLabel(),
                SizedBox(height: 4.h),
                _EarningAmount(amount: todayEarning),
                SizedBox(height: 4.h),
                Text(
                  'Keep up the great work!',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          const _MoneyBagIllustration(),
        ],
      ),
    );
  }
}

class _EarningIconCircle extends StatelessWidget {
  const _EarningIconCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: AppColors.onlineIndicator.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.trending_up_rounded,
        color: AppColors.onlineIndicator,
        size: 24.sp,
      ),
    );
  }
}

class _EarningLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "TODAY'S EARNING",
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.subtitleText,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(width: 8.w),
        const _LiveBadge(),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.onlineIndicator.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              color: AppColors.onlineIndicator,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Live',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.onlineIndicator,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarningAmount extends StatelessWidget {
  final String amount;

  const _EarningAmount({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.currency_rupee_rounded, size: 22.sp, color: AppColors.primaryColor),
        Text(
          amount,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _MoneyBagIllustration extends StatelessWidget {
  const _MoneyBagIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.onlineIndicator.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.local_atm_rounded, size: 36.sp, color: AppColors.onlineIndicator.withOpacity(0.6)),
              Positioned(
                bottom: 4.h,
                right: 4.w,
                child: Icon(Icons.trending_up_rounded, size: 18.sp, color: AppColors.onlineIndicator),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
