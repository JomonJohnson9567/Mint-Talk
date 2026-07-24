import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';

class ReferralStatusChip extends StatelessWidget {
  final String status;

  const ReferralStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isRewarded = normalized == 'rewarded' || normalized == 'completed';
    final isPending = normalized == 'pending';

    final backgroundColor = isRewarded
        ? AppColors.green.withValues(alpha: 0.12)
        : isPending
        ? Colors.orange.withValues(alpha: 0.14)
        : AppColors.grey.withValues(alpha: 0.12);

    final foregroundColor = isRewarded
        ? AppColors.green
        : isPending
        ? Colors.orange.shade800
        : AppColors.subtitleText;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
