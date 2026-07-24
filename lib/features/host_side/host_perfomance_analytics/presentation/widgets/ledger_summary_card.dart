import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class LedgerSummaryCard extends StatelessWidget {
  final String title;
  final String valueText;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const LedgerSummaryCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14.sp, color: iconColor),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 13.sp, color: AppColors.subtitleText),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}
