import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_status_chip.dart';

class RechargeHistoryItemCard extends StatelessWidget {
  final RechargeHistoryItem item;

  const RechargeHistoryItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColorForStatus(item.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForStatus(item.status),
              color: accentColor,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.currency} ${_formatMoney(item.amount)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    RechargeHistoryStatusChip(status: item.status),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '${item.points.toString()} points credited',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.subtitleText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _formatDate(item.createdAt),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.subtitleText,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction ID',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.subtitleText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        item.transactionId.isEmpty
                            ? 'Unavailable'
                            : item.transactionId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatMoney(num amount) {
    final isWholeNumber = amount == amount.toInt();
    return isWholeNumber ? amount.toInt().toString() : amount.toStringAsFixed(2);
  }

  static String _formatDate(DateTime dateTime) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}, '
        '$hour:$minute $period';
  }

  static Color _accentColorForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'completed' || normalized == 'success') {
      return AppColors.onlineIndicator;
    }
    if (normalized == 'pending' || normalized == 'processing') {
      return AppColors.orange;
    }
    if (normalized == 'failed' || normalized == 'error') {
      return AppColors.red;
    }
    return AppColors.primaryColor;
  }

  static IconData _iconForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized == 'completed' || normalized == 'success') {
      return Icons.arrow_downward_rounded;
    }
    if (normalized == 'pending' || normalized == 'processing') {
      return Icons.hourglass_bottom_rounded;
    }
    if (normalized == 'failed' || normalized == 'error') {
      return Icons.warning_rounded;
    }
    return Icons.receipt_long_rounded;
  }
}
