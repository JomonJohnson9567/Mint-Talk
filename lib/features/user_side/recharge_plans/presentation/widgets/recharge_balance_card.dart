import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';

import 'package:mint_talk/core/widgets/plum_blob.dart';

/// Plum card showing the user's current coin balance.
class RechargeBalanceCard extends StatelessWidget {
  const RechargeBalanceCard({super.key});

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
          height: 78.cw,
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
                right: -26.cw,
                bottom: -46.cw,
                child: PlumBlob(size: 112.cw),
              ),
              Positioned(
                right: 54.cw,
                bottom: -62.cw,
                child: PlumBlob(size: 100.cw),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.cw),
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.rechargeCoinStack,
                      width: 64.cw,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 14.cw),
                    Container(
                      width: 1,
                      height: 40.cw,
                      color: AppColors.white.withValues(alpha: 0.25),
                    ),
                    SizedBox(width: 16.cw),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.yourBalance,
                            style: TextStyle(
                              fontSize: 12.5.csp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          SizedBox(height: 2.cw),
                          BlocBuilder<WalletCubit, WalletState>(
                            buildWhen: (previous, current) =>
                                previous.balance != current.balance,
                            builder: (context, state) {
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: IndianNumberFormat.format(
                                          state.balance,
                                        ),
                                        style: GoogleFonts.nunito(
                                          fontSize: 28.csp,
                                          fontWeight: FontWeight.w800,
                                          height: 1.1,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' ${AppTexts.coinsSuffix}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 18.csp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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
