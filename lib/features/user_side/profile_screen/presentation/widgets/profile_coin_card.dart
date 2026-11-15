import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/core/widgets/plum_blob.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';

/// Plum card with the user's coin balance and a shortcut to recharge.
class ProfileCoinCard extends StatelessWidget {
  const ProfileCoinCard({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.cw);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          height: 66.cw,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.balanceCardStart, AppColors.primaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                left: 150.cw,
                top: -40.cw,
                child: PlumBlob(size: 70.cw),
              ),
              Positioned(
                right: -20.cw,
                bottom: -50.cw,
                child: PlumBlob(size: 100.cw),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.cw),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.rechargeCoinStack,
                      width: 56.cw,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 12.cw),
                    const Expanded(child: _BalanceText()),
                    SizedBox(width: 8.cw),
                    const _RechargeButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceText extends StatelessWidget {
  const _BalanceText();

  @override
  Widget build(BuildContext context) {
    final balance = context.select<WalletCubit, int>(
      (cubit) => cubit.state.balance,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: IndianNumberFormat.format(balance),
              style: GoogleFonts.nunito(
                fontSize: 30.csp,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: ' ${AppTexts.coinsSuffix}',
              style: GoogleFonts.nunito(
                fontSize: 16.csp,
                fontWeight: FontWeight.w600,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        style: const TextStyle(color: AppColors.white),
      ),
    );
  }
}

class _RechargeButton extends StatelessWidget {
  const _RechargeButton();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.cw);

    return Material(
      color: AppColors.pricePill,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.rechargePlansScreen),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 8.cw),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAssets.rechargeCoin, width: 22.cw, height: 22.cw),
              SizedBox(width: 8.cw),
              Text(
                AppTexts.recharge,
                style: GoogleFonts.nunito(
                  fontSize: 15.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
