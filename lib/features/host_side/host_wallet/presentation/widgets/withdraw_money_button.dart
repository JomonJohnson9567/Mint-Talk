// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WithdrawMoneyButton extends StatelessWidget {
  final VoidCallback? onTap;

  const WithdrawMoneyButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFF4A52DA), Color(0xFF6870E8)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: isEnabled ? null : AppColors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isEnabled
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Container(
                  height: 52.h,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_rounded,
                        color: isEnabled ? AppColors.white : AppColors.subtitleText,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Withdraw Money',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: isEnabled ? AppColors.white : AppColors.subtitleText,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 12.sp, color: AppColors.subtitleText),
            SizedBox(width: 4.w),
            Text(
              'Secure & Instant Transfers',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.subtitleText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
