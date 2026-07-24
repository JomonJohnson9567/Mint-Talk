import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';

class WithdrawalHistorySection extends StatelessWidget {
  final List<HostWithdrawalEntryEntity> withdrawals;

  const WithdrawalHistorySection({
    super.key,
    required this.withdrawals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
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
              Icon(Icons.receipt_long_rounded, size: 18.sp, color: AppColors.primaryColor),
              SizedBox(width: 8.w),
              Text(
                'Recent Withdrawals',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (withdrawals.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Text(
                'No withdrawal requests yet.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.subtitleText,
                ),
              ),
            )
          else
            Column(
              children: withdrawals
                  .take(5)
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _WithdrawalItemCard(item: item),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _WithdrawalItemCard extends StatelessWidget {
  final HostWithdrawalEntryEntity item;

  const _WithdrawalItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status.toLowerCase()) {
      'approved' => AppColors.onlineIndicator,
      'rejected' => AppColors.callEndedStatus,
      _ => AppColors.orange,
    };

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_rounded, size: 18.sp, color: statusColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹ ${item.amount.round()}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.payoutMethod} • ${item.createdAt.toLocal()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.subtitleText),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              item.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
