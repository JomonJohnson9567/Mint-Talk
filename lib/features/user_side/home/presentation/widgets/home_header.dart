// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        children: [
          Image.asset(AppAssets.logo, width: 40.w, height: 40.h),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.mintTalk,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                Text(
                  AppTexts.whereConversationsHaveValue,
                  style: TextStyle(fontSize: 10.sp, color: AppColors.textGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          BlocBuilder<WalletCubit, WalletState>(
            builder: (context, state) {
              // Trigger fetch if not already loading, loaded, or successfully fetched before
              if (state.status == WalletStatus.initial ||
                  state.status == WalletStatus.error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.read<WalletCubit>().fetchBalance();
                  }
                });
              }

              String balance = state.balance.toString();
              if (state.status == WalletStatus.loading && state.balance == 0) {
                balance = '...';
              }

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.rechargePlansScreen);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: AppColors.borderSoft, width: 1.w),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.moneyBag, width: 22.w, height: 22.h),
                      SizedBox(width: 8.w),
                      Text(
                        balance,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.add_circle,
                        size: 16.sp,
                        color: AppColors.termsIcon,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
