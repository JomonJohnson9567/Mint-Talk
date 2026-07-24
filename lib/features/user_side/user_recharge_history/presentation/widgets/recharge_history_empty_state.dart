import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';

class RechargeHistoryEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const RechargeHistoryEmptyState({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 92.w,
              height: 92.w,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 44.sp,
                color: AppColors.primaryColor,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No recharge history yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your completed and pending wallet recharges will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
                color: AppColors.subtitleText,
              ),
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: onRefresh,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
