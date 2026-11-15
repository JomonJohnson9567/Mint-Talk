import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';

import 'plan_detail_section_card.dart';

/// Coins, bonus, current and post-recharge balance, and the total to pay.
class PlanPaymentSummary extends StatelessWidget {
  const PlanPaymentSummary({super.key, required this.plan});

  final RechargePlanEntity plan;

  @override
  Widget build(BuildContext context) {
    final bonus = plan.bonusPoints ?? 0;

    return PlanDetailSectionCard(
      child: BlocBuilder<WalletCubit, WalletState>(
        buildWhen: (previous, current) => previous.balance != current.balance,
        builder: (context, state) {
          final afterRecharge = state.balance + plan.coinAmount + bonus;

          return Column(
            children: [
              _SummaryRow(
                label: AppTexts.coinsSuffix,
                value: IndianNumberFormat.format(plan.coinAmount),
                showCoin: true,
              ),
              if (bonus > 0)
                _SummaryRow(
                  label: AppTexts.bonusCoins,
                  value: '+${IndianNumberFormat.format(bonus)}',
                ),
              _SummaryRow(
                label: AppTexts.currentBalance,
                value: IndianNumberFormat.format(state.balance),
              ),
              _SummaryRow(
                label: AppTexts.balanceAfterRecharge,
                value: IndianNumberFormat.format(afterRecharge),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.cw),
                child: Divider(
                  height: 1,
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppTexts.totalAmount,
                      style: TextStyle(
                        fontSize: 15.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                      ),
                    ),
                  ),
                  Text(
                    '${AppTexts.rupeeSymbol} ${IndianNumberFormat.format(plan.numericPrice)}',
                    style: GoogleFonts.nunito(
                      fontSize: 20.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.showCoin = false,
  });

  final String label;
  final String value;
  final bool showCoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.cw),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.csp, color: AppColors.plumMuted),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.csp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
            ),
          ),
          if (showCoin) ...[
            SizedBox(width: 4.cw),
            Image.asset(AppAssets.rechargeCoin, width: 16.cw),
          ],
        ],
      ),
    );
  }
}
