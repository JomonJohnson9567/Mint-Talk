import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';

class RechargeSuccessScreen extends StatelessWidget {
  final int addedPoints;
  final int totalBalance;

  const RechargeSuccessScreen({
    super.key,
    required this.addedPoints,
    required this.totalBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const _AnimatedSuccessIcon(),
              SizedBox(height: 32.h),
              Text(
                'Recharge Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your wallet has been credited with $addedPoints points.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textGrey,
                ),
              ),
              SizedBox(height: 48.h),
              _BalanceInfoCard(totalBalance: totalBalance),
              const Spacer(flex: 3),
              PrimaryButton(
                text: 'Done',
                onPressed: () {
                  Navigator.pop(context); // Go back to where it was
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSuccessIcon extends StatelessWidget {
  const _AnimatedSuccessIcon();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 120.w,
            width: 120.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 60.sp,
            ),
          ),
        );
      },
    );
  }
}

class _BalanceInfoCard extends StatelessWidget {
  final int totalBalance;

  const _BalanceInfoCard({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Updated Balance',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textGrey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '$totalBalance Points',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.primaryColor,
            size: 32.sp,
          ),
        ],
      ),
    );
  }
}
