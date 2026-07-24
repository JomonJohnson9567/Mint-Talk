import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WalletHeroSection extends StatelessWidget {
  const WalletHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet',
                  style: TextStyle(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Track your earnings and manage\nwithdrawals',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.subtitleText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const _WalletIllustration(),
        ],
      ),
    );
  }
}

class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sparkle dots
        Positioned(
          top: 6.h,
          right: 8.w,
          child: Icon(Icons.star_rounded, color: AppColors.primaryColor.withValues(alpha: 0.4), size: 8.sp),
        ),
        Positioned(
          top: 20.h,
          left: 4.w,
          child: Icon(Icons.star_rounded, color: AppColors.primaryColor.withValues(alpha: 0.3), size: 6.sp),
        ),
        Container(
          width: 110.w,
          height: 90.h,
          alignment: Alignment.center,
          child: _WalletIcon(),
        ),
      ],
    );
  }
}

class _WalletIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/wallet.png',
      width: 86.w,
      height: 70.h,
      fit: BoxFit.contain,
    );
  }
}

