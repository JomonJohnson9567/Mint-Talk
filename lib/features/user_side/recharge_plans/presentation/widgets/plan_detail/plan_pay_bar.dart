import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';

/// Sticky bottom bar with the "Pay ₹X" button that starts the recharge.
class PlanPayBar extends StatelessWidget {
  const PlanPayBar({super.key, required this.plan});

  final RechargePlanEntity plan;

  /// Opens Razorpay checkout directly; the user picks the method there.
  void _onPay(BuildContext context) {
    context.read<WalletCubit>().startRecharge(plan.id);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.rechargeBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 10.cw),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<WalletCubit, WalletState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) {
                  final isLoading =
                      state.status == WalletStatus.paymentProcessing;
                  return PrimaryButton(
                    text:
                        '${AppTexts.pay} ${AppTexts.rupeeSymbol}${IndianNumberFormat.format(plan.numericPrice)}',
                    height: 52.cw,
                    isLoading: isLoading,
                    disabledBackgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.6,
                    ),
                    disabledForegroundColor: AppColors.white,
                    textStyle: GoogleFonts.nunito(
                      fontSize: 16.csp,
                      fontWeight: FontWeight.w800,
                    ),
                    onPressed: isLoading ? null : () => _onPay(context),
                  );
                },
              ),
              SizedBox(height: 8.cw),
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
      ),
    );
  }
}
