import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_state.dart';
import '../../data/models/recharge_plan_item.dart';

class PlanDetailArgs {
  final RechargePlanItem plan;
  final Color accentColor;

  PlanDetailArgs({required this.plan, required this.accentColor});
}

class PlanDetailScreen extends StatelessWidget {
  final PlanDetailArgs args;

  const PlanDetailScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    final plan = args.plan;
    final accentColor = args.accentColor;

    return BlocListener<WalletCubit, WalletState>(
      listener: (context, state) {
        if (state.status == WalletStatus.paymentSuccess) {
          final coinsValue = int.tryParse(plan.coins.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.rechargeSuccess,
            arguments: {
              'addedPoints': coinsValue,
              'totalBalance': state.balance,
            },
          );
        } else if (state.status == WalletStatus.error) {
          _showSnackBar(context, state.errorMessage ?? "An error occurred");
        } else if (state.status == WalletStatus.paymentFailure) {
          _showSnackBar(context, state.errorMessage ?? 'Payment failed');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(
          title: AppTexts.planDetails,
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PlanHeroCard(plan: plan, accentColor: accentColor),
                SizedBox(height: 24.h),
                _PlanBenefitsSection(accentColor: accentColor),
                SizedBox(height: 24.h),
                _PaymentSummarySection(plan: plan, accentColor: accentColor),
                SizedBox(height: 32.h),
                _RechargeButton(
                  accentColor: accentColor,
                  planId: plan.id,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _PlanHeroCard extends StatelessWidget {
  final RechargePlanItem plan;
  final Color accentColor;

  const _PlanHeroCard({required this.plan, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor,
            accentColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (plan.badgeText != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                plan.badgeText!,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Image.asset(
                AppAssets.moneyBag,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            plan.coins,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            AppTexts.coinsSuffix,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBenefitsSection extends StatelessWidget {
  final Color accentColor;

  const _PlanBenefitsSection({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.planBenefits,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 16.h),
        _BenefitItem(
          icon: Icons.flash_on_rounded,
          title: AppTexts.instantActivation,
          accentColor: accentColor,
        ),
        SizedBox(height: 12.h),
        _BenefitItem(
          icon: Icons.security_rounded,
          title: AppTexts.securePayment,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: accentColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentSummarySection extends StatelessWidget {
  final RechargePlanItem plan;
  final Color accentColor;

  const _PaymentSummarySection({required this.plan, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.paymentSummary,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 20.h),
          _SummaryRow(label: AppTexts.subtotal, value: plan.price),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(color: AppColors.borderSoft),
          ),
          _SummaryRow(
            label: AppTexts.totalAmount,
            value: plan.price,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
            color: isTotal ? AppColors.black : AppColors.subtitleText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: isTotal ? AppColors.primaryColor : AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _RechargeButton extends StatelessWidget {
  final Color accentColor;
  final String planId;

  const _RechargeButton({required this.accentColor, required this.planId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final isLoading = state.status == WalletStatus.paymentProcessing;
        return ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  context.read<WalletCubit>().startRecharge(planId);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 8,
            shadowColor: accentColor.withValues(alpha: 0.4),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  AppTexts.rechargeNow,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
        );
      },
    );
  }
}
