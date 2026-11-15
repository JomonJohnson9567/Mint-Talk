import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.cw, 8.cw, 14.cw, 4.cw),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                AppAssets.mintTalkWordmark,
                height: 26.cw,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8.cw),
          const _NotificationBell(),
          SizedBox(width: 8.cw),
          const CoinBalancePill(),
        ],
      ),
    );
  }
}

BoxDecoration _whiteChipDecoration({BorderRadius? borderRadius}) =>
    BoxDecoration(
      color: AppColors.white,
      shape: borderRadius == null ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryColor.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationsCubit, bool>(
      (cubit) => cubit.state.unreadCount > 0,
    );

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.userNotificationsScreen),
      child: Container(
        width: 34.cw,
        height: 34.cw,
        decoration: _whiteChipDecoration(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_rounded,
              size: 18.csp,
              color: AppColors.primaryColor,
            ),
            if (hasUnread)
              Positioned(
                top: 7.cw,
                right: 8.cw,
                child: Container(
                  width: 7.cw,
                  height: 7.cw,
                  decoration: BoxDecoration(
                    color: AppColors.audioAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5.cw),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Wallet balance chip; tapping it opens the recharge plans.
class CoinBalancePill extends StatelessWidget {
  final String iconAsset;

  const CoinBalancePill({super.key, this.iconAsset = AppAssets.moneyBag});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (previous, current) =>
          previous.balance != current.balance ||
          previous.status != current.status,
      builder: (context, state) {
        String balance = state.balance.toString();
        if (state.status == WalletStatus.loading && state.balance == 0) {
          balance = '...';
        }

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.rechargePlansScreen);
          },
          child: Container(
            height: 34.cw,
            padding: EdgeInsets.only(left: 6.cw, right: 4.cw),
            decoration: _whiteChipDecoration(
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(iconAsset, width: 20.cw, height: 20.cw),
                SizedBox(width: 6.cw),
                Text(
                  balance,
                  style: TextStyle(
                    fontSize: 13.csp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumDeep,
                  ),
                ),
                SizedBox(width: 6.cw),
                Container(
                  width: 24.cw,
                  height: 24.cw,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 16.csp,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
