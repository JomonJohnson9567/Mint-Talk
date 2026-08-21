import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_targets/domain/entities/host_target_entity.dart';

class TargetProgressCard extends StatelessWidget {
  final HostTargetEntity target;

  const TargetProgressCard({super.key, required this.target});

  IconData get _typeIcon => switch (target.targetType) {
        'call_minutes' => Icons.timer_rounded,
        'points_earned' => Icons.stars_rounded,
        'total_calls' => Icons.call_rounded,
        _ => Icons.track_changes_rounded,
      };

  String get _typeLabel => switch (target.targetType) {
        'call_minutes' => 'Call Minutes',
        'points_earned' => 'Points Earned',
        'total_calls' => 'Total Calls',
        _ => target.targetType,
      };

  String get _periodLabel =>
      target.period.isEmpty ? '' : target.period[0].toUpperCase() + target.period.substring(1);

  @override
  Widget build(BuildContext context) {
    final accentColor = target.isAchieved ? AppColors.onlineIndicator : AppColors.primaryColor;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_typeIcon, size: 16.sp, color: accentColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _typeLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
              ),
              Text(
                '${target.currentValue} / ${target.targetValue}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: LinearProgressIndicator(
              value: target.progress,
              minHeight: 7.h,
              backgroundColor: AppColors.lightGrey,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _InfoChip(label: 'Period', value: _periodLabel),
              if (target.callTypeFilter != 'all')
                _InfoChip(
                  label: 'Type',
                  value: target.callTypeFilter[0].toUpperCase() +
                      target.callTypeFilter.substring(1),
                ),
              _InfoChip(
                label: 'Status',
                value: target.status.replaceAll('_', ' '),
                valueColor: accentColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoChip({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FC),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.black,
        ),
      ),
    );
  }
}
