import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/payment_method.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

/// Bottom sheet where the user picks how to pay before Razorpay opens.
/// Completes with the chosen [PaymentMethod], or null if dismissed.
class PaymentMethodSheet extends StatelessWidget {
  const PaymentMethodSheet({super.key, required this.plan});

  final RechargePlanEntity plan;

  static Future<PaymentMethod?> show(
    BuildContext context,
    RechargePlanEntity plan,
  ) {
    return showModalBottomSheet<PaymentMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PaymentMethodSheet(plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final price =
        '${AppTexts.rupeeSymbol} ${IndianNumberFormat.format(plan.numericPrice)}';
    final coins = IndianNumberFormat.format(plan.coinAmount);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.rechargeBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.cw)),
      ),
      padding: EdgeInsets.fromLTRB(16.cw, 10.cw, 16.cw, 16.cw),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.cw,
                height: 4.cw,
                decoration: BoxDecoration(
                  color: AppColors.plumHint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16.cw),
            Text(
              AppTexts.choosePaymentMethod,
              style: GoogleFonts.nunito(
                fontSize: 18.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 4.cw),
            Text(
              '${AppTexts.paying} $price for $coins ${AppTexts.coinsSuffix.toLowerCase()}',
              style: TextStyle(fontSize: 12.5.csp, color: AppColors.plumMuted),
            ),
            SizedBox(height: 16.cw),
            const _MethodTile(
              method: PaymentMethod.upi,
              icon: Icons.qr_code_scanner_rounded,
              title: AppTexts.upi,
              description: AppTexts.upiDesc,
            ),
            SizedBox(height: 10.cw),
            const _MethodTile(
              method: PaymentMethod.card,
              icon: Icons.credit_card_rounded,
              title: AppTexts.cards,
              description: AppTexts.cardsDesc,
            ),
            SizedBox(height: 10.cw),
            const _MethodTile(
              method: PaymentMethod.netbanking,
              icon: Icons.account_balance_rounded,
              title: AppTexts.netBanking,
              description: AppTexts.netBankingDesc,
            ),
            SizedBox(height: 14.cw),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 13.csp,
                  color: AppColors.plumHint,
                ),
                SizedBox(width: 4.cw),
                Text(
                  AppTexts.securePayments,
                  style: TextStyle(
                    fontSize: 11.5.csp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.plumHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.method,
    required this.icon,
    required this.title,
    required this.description,
  });

  final PaymentMethod method;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.cw);

    return Material(
      color: AppColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(method),
        child: Padding(
          padding: EdgeInsets.all(14.cw),
          child: Row(
            children: [
              Container(
                width: 42.cw,
                height: 42.cw,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryColor, size: 20.csp),
              ),
              SizedBox(width: 12.cw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    SizedBox(height: 2.cw),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.csp,
                        color: AppColors.plumMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.cw),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.csp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
