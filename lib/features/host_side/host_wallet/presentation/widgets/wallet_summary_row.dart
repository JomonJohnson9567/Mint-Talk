// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WalletSummaryItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String amount;

  const WalletSummaryItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.amount,
  });
}

class WalletSummaryRow extends StatelessWidget {
  final List<WalletSummaryItem> items;

  const WalletSummaryRow({
    super.key,
    this.items = const [
      WalletSummaryItem(
        icon: Icons.account_balance_wallet_rounded,
        iconBgColor: Color(0xFFEEEFFC),
        iconColor: Color(0xFF4A52DA),
        label: 'Total Earnings',
        amount: '₹ 12,540',
      ),
      WalletSummaryItem(
        icon: Icons.upload_rounded,
        iconBgColor: Color(0xFFE6F4FF),
        iconColor: Color(0xFF1E88E5),
        label: 'Total Withdrawn',
        amount: '₹ 8,430',
      ),
      WalletSummaryItem(
        icon: Icons.access_time_rounded,
        iconBgColor: Color(0xFFFFF3E0),
        iconColor: Color(0xFFFF8F00),
        label: 'Pending',
        amount: '₹ 1,230',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: items
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: _SummaryCard(item: item),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final WalletSummaryItem item;

  const _SummaryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.h,
                decoration: BoxDecoration(
                  color: item.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 14.sp, color: item.iconColor),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 14.sp, color: AppColors.subtitleText),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitleText,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            item.amount,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
