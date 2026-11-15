import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

import 'package:mint_talk/core/widgets/plum_blob.dart';
import '../popular_pill.dart';

/// Plum hero card at the top of the plan details screen: coin stack, coin
/// count, bonus and price — styled like the balance card on the plans list.
class PlanDetailHero extends StatelessWidget {
  const PlanDetailHero({super.key, required this.plan, this.isPopular = false});

  final RechargePlanEntity plan;
  final bool isPopular;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.cw);
    final bonus = plan.bonusPoints ?? 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.balanceCardStart, AppColors.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -34.cw,
                bottom: -54.cw,
                child: PlumBlob(size: 150.cw),
              ),
              Positioned(
                left: -40.cw,
                top: -50.cw,
                child: PlumBlob(size: 120.cw),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.cw, 18.cw, 20.cw, 22.cw),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      child: isPopular
                          ? const PopularPill(inverted: true)
                          : SizedBox(height: 4.cw),
                    ),
                    SizedBox(height: 10.cw),
                    Image.asset(
                      AppAssets.rechargeCoinStack,
                      height: 104.cw,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 12.cw),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        IndianNumberFormat.format(plan.coinAmount),
                        maxLines: 1,
                        style: GoogleFonts.nunito(
                          fontSize: 36.csp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      AppTexts.coinsSuffix,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.csp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (bonus > 0) ...[
                      SizedBox(height: 8.cw),
                      Align(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.cw,
                            vertical: 4.cw,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '+${IndianNumberFormat.format(bonus)} ${AppTexts.bonusCoins.toLowerCase()}',
                            style: TextStyle(
                              fontSize: 11.5.csp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 14.cw),
                    Align(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.cw,
                          vertical: 7.cw,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pricePill,
                          borderRadius: BorderRadius.circular(14.cw),
                        ),
                        child: Text(
                          '${AppTexts.rupeeSymbol} ${IndianNumberFormat.format(plan.numericPrice)}',
                          style: TextStyle(
                            fontSize: 18.csp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.plumDeep,
                          ),
                        ),
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
