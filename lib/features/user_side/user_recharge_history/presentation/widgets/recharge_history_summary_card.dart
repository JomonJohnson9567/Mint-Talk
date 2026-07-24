import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';

class RechargeHistorySummaryCard extends StatelessWidget {
  final List<RechargeHistoryItem> history;

  const RechargeHistorySummaryCard({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = history.where((item) => item.isCompleted).length;
    final pendingCount = history.where((item) => item.isPending).length;
    final totalPoints = history.fold<int>(0, (sum, item) => sum + item.points);
    final latest = history.isNotEmpty ? history.first : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.tealBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recharge History',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'A ledger of your wallet top-ups and point credits.',
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.82),
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  value: history.length.toString(),
                  label: 'Transactions',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  value: totalPoints.toString(),
                  label: 'Points Credited',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  value: completedCount.toString(),
                  label: 'Completed',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (latest != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppColors.white, size: 18.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Latest recharge ${latest.points} points • ${latest.currency} ${latest.amount}',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (pendingCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        '$pendingCount pending',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.82),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
