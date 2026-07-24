import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';

class RechargeHistoryStatusChip extends StatelessWidget {
  final String status;

  const RechargeHistoryStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final config = _StatusChipConfig.fromStatus(normalized);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14.sp, color: config.foregroundColor),
          SizedBox(width: 5.w),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: config.foregroundColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChipConfig {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;

  const _StatusChipConfig({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  factory _StatusChipConfig.fromStatus(String status) {
    if (status == 'completed' || status == 'success') {
      return _StatusChipConfig(
        label: 'COMPLETED',
        icon: Icons.check_circle_rounded,
        foregroundColor: AppColors.onlineIndicator,
        backgroundColor: AppColors.onlineIndicator.withValues(alpha: 0.1),
        borderColor: AppColors.onlineIndicator.withValues(alpha: 0.2),
      );
    }

    if (status == 'pending' || status == 'processing') {
      return _StatusChipConfig(
        label: 'PENDING',
        icon: Icons.schedule_rounded,
        foregroundColor: AppColors.orange,
        backgroundColor: AppColors.orange.withValues(alpha: 0.12),
        borderColor: AppColors.orange.withValues(alpha: 0.22),
      );
    }

    if (status == 'failed' || status == 'error') {
      return _StatusChipConfig(
        label: 'FAILED',
        icon: Icons.error_rounded,
        foregroundColor: AppColors.red,
        backgroundColor: AppColors.red.withValues(alpha: 0.1),
        borderColor: AppColors.red.withValues(alpha: 0.2),
      );
    }

    return _StatusChipConfig(
      label: status.isEmpty ? 'UNKNOWN' : status.toUpperCase(),
      icon: Icons.help_rounded,
      foregroundColor: AppColors.subtitleText,
      backgroundColor: AppColors.subtitleText.withValues(alpha: 0.08),
      borderColor: AppColors.subtitleText.withValues(alpha: 0.15),
    );
  }
}
