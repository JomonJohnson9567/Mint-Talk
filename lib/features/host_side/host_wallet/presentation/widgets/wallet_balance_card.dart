// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WalletBalanceCard extends StatelessWidget {
  final int balance;
  final VoidCallback? onWithdrawTap;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    this.onWithdrawTap,
  });

  @override
  Widget build(BuildContext context) {
    final canWithdraw = balance >= 500;

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
                _BalanceAmount(amount: balance.toString()),
                SizedBox(height: 6.h),
                _ReadyToWithdraw(canWithdraw: canWithdraw),
              ],
            ),
          ),
          _WithdrawButton(
            onTap: canWithdraw ? onWithdrawTap : null,
          ),
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
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3E6),
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
        Flexible(
          child: Text(
            'AVAILABLE BALANCE',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitleText,
              letterSpacing: 0.5,
            ),
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
  final bool canWithdraw;

  const _ReadyToWithdraw({required this.canWithdraw});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          canWithdraw ? Icons.check_circle_rounded : Icons.info_outline_rounded,
          size: 14.sp,
          color: canWithdraw ? AppColors.onlineIndicator : AppColors.subtitleText,
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            canWithdraw ? 'Ready to withdraw' : 'Min withdrawal ₹500',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: canWithdraw ? AppColors.onlineIndicator : AppColors.subtitleText,
            ),
          ),
        ),
      ],
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _WithdrawButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final color = isEnabled ? const Color(0xFFF0A500) : AppColors.subtitleText.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_rounded, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              'Withdraw',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
