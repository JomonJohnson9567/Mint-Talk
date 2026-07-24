// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WalletBalanceCard extends StatelessWidget {
  final String balance;

  const WalletBalanceCard({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF0A500).withOpacity(0.4), width: 1.5),
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
          const _WalletIconCircle(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BalanceLabel(),
                SizedBox(height: 4.h),
                _BalanceAmount(amount: balance),
                SizedBox(height: 6.h),
                const _ReadyToWithdraw(),
              ],
            ),
          ),
          const _WithdrawButton(),
        ],
      ),
    );
  }
}

class _WalletIconCircle extends StatelessWidget {
  const _WalletIconCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E6),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.account_balance_wallet_rounded,
        color: const Color(0xFFF0A500),
        size: 24.sp,
      ),
    );
  }
}

class _BalanceLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'AVAILABLE BALANCE',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.subtitleText,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.info_outline_rounded, size: 12.sp, color: AppColors.subtitleText),
      ],
    );
  }
}

class _BalanceAmount extends StatelessWidget {
  final String amount;

  const _BalanceAmount({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.currency_rupee_rounded, size: 22.sp, color: const Color(0xFFF0A500)),
        Text(
          amount,
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF0A500),
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _ReadyToWithdraw extends StatelessWidget {
  const _ReadyToWithdraw();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_rounded, size: 14.sp, color: AppColors.onlineIndicator),
        SizedBox(width: 4.w),
        Text(
          'Ready to withdraw',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.onlineIndicator,
          ),
        ),
      ],
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFF0A500).withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_rounded, size: 14.sp, color: const Color(0xFFF0A500)),
          SizedBox(width: 6.w),
          Text(
            'Withdraw',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF0A500),
            ),
          ),
        ],
      ),
    );
  }
}
