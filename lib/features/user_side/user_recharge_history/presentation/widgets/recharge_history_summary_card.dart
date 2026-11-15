import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/core/widgets/plum_blob.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';

/// Plum hero card at the top of the recharge history list — styled like the
/// balance card on the recharge plans screen.
class RechargeHistorySummaryCard extends StatelessWidget {
  final List<RechargeHistoryItem> history;

  const RechargeHistorySummaryCard({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final completed = history.where((item) => item.isCompleted);
    final completedCount = completed.length;
    final pendingCount = history.where((item) => item.isPending).length;
    // Only completed recharges have actually landed in the wallet.
    final totalCoins = completed.fold<int>(0, (sum, item) => sum + item.points);
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
                right: -30.cw,
                top: -40.cw,
                child: PlumBlob(size: 112.cw),
              ),
              Positioned(
                left: -36.cw,
                bottom: -58.cw,
                child: PlumBlob(size: 100.cw),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.cw, 16.cw, 16.cw, 14.cw),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppAssets.rechargeCoinStack,
                          width: 60.cw,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.totalCoinsCredited,
                                style: TextStyle(
                                  fontSize: 12.5.csp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white.withValues(
                                    alpha: 0.85,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.cw),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: IndianNumberFormat.format(
                                          totalCoins,
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.cw),
                    Wrap(
                      spacing: 8.cw,
                      runSpacing: 8.cw,
                      children: [
                        _SummaryStat(
                          value: history.length,
                          label: AppTexts.recharges,
                        ),
                        _SummaryStat(
                          value: completedCount,
                          label: AppTexts.completed,
                        ),
                        if (pendingCount > 0)
                          _SummaryStat(
                            value: pendingCount,
                            label: AppTexts.pending,
                          ),
                      ],
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

class _SummaryStat extends StatelessWidget {
  final int value;
  final String label;

  const _SummaryStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 5.cw),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: IndianNumberFormat.format(value),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: ' $label'),
          ],
        ),
        style: TextStyle(
          fontSize: 12.csp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}
