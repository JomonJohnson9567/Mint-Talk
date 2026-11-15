import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';

/// Plum gradient card with the withdrawable balance and the backend's
/// minimum withdrawal, with a faded wallet glyph on the right.
class WalletBalanceCard extends StatelessWidget {
  final double balance;

  /// Hidden when 0 (the API didn't send a minimum).
  final double minWithdrawalAmount;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.minWithdrawalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.cw, 22.cw, 20.cw, 22.cw),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.hostGoOnlineStart, AppColors.balanceCardStart],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.75],
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.availableBalance,
                  style: TextStyle(
                    fontSize: 15.csp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
                SizedBox(height: 6.cw),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹${IndianNumberFormat.format(balance)}',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 40.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                if (minWithdrawalAmount > 0) ...[
                  SizedBox(height: 10.cw),
                  Text(
                    AppTexts.minWithdrawalNote(
                      IndianNumberFormat.format(minWithdrawalAmount),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.csp,
                      color: AppColors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.cw),
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 60.csp,
            color: AppColors.white.withValues(alpha: 0.16),
          ),
        ],
      ),
    );
  }
}
