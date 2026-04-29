import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_section.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_data.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_plan_section_widget.dart';

class ScreenContents extends StatelessWidget {
  const ScreenContents({
    super.key,
    required this.contentWidth,
  });

  final double contentWidth;

  @override
  Widget build(BuildContext context) {
    // Trigger plan fetch on build
    context.read<WalletCubit>().fetchPlans();

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 720 ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding.w,
            8.h,
            horizontalPadding.w,
            28.h,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: BlocBuilder<WalletCubit, WalletState>(
                buildWhen: (previous, current) =>
                    current.status == WalletStatus.plansLoading ||
                    current.status == WalletStatus.plansLoaded ||
                    current.status == WalletStatus.plansError,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _RechargeOverviewCard(),
                      SizedBox(height: 18.h),
                      if (state.status == WalletStatus.plansLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      else if (state.status == WalletStatus.plansLoaded)
                        ..._buildPlanSections(state.plans)
                      else
                        // Fallback to dummy data if not loaded or error
                        ..._buildPlanSections([]),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildPlanSections(List<RechargePlanItem> mergedPlans) {
    // If no plans loaded yet, just show dummy sections
    if (mergedPlans.isEmpty) {
      return RechargePlanData.sections.map((section) {
        return Padding(
          padding: EdgeInsets.only(bottom: 18.h),
          child: RechargePlanSectionWidget(section: section),
        );
      }).toList();
    }

    // Identify API plans (those not in dummy data)
    // For simplicity, we'll group API plans into "Verified Packages"
    // and then show the standard dummy sections.
    final dummyIds = RechargePlanData.sections
        .expand((s) => s.plans)
        .map((p) => p.id)
        .toSet();

    final apiPlans = mergedPlans.where((p) => !dummyIds.contains(p.id)).toList();

    final List<Widget> sections = [];

    // 1. Add API Plans Section if available
    if (apiPlans.isNotEmpty) {
      sections.add(
        Padding(
          padding: EdgeInsets.only(bottom: 18.h),
          child: RechargePlanSectionWidget(
            section: RechargePlanSection(
              title: "Verified Packages",
              plans: apiPlans,
            ),
          ),
        ),
      );
    }

    // 2. Add Original Dummy Sections
    for (var dummySection in RechargePlanData.sections) {
      sections.add(
        Padding(
          padding: EdgeInsets.only(bottom: 18.h),
          child: RechargePlanSectionWidget(section: dummySection),
        ),
      );
    }

    return sections;
  }
}

class _RechargeOverviewCard extends StatelessWidget {
  const _RechargeOverviewCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 560;

        return Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.tealBackground,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.18),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OverviewContent(isCompact: isCompact),
                    SizedBox(height: 18.h),
                    const Center(child: _OverviewIcon()),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _OverviewContent(isCompact: isCompact)),
                    SizedBox(width: 16.w),
                    const _OverviewIcon(),
                  ],
                ),
        );
      },
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                'Wallet Top-Up',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            BlocBuilder<WalletCubit, WalletState>(
              builder: (context, state) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet,
                          color: AppColors.white, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        '${state.balance}',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 14.h),
        Text(
          'Choose a pack and recharge in seconds.',
          style: TextStyle(
            color: AppColors.white,
            fontSize: isCompact ? 24.sp : 26.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Simple plans, instant credit, and the same MintTalk look you already know.',
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.84),
            fontSize: 12.5.sp,
            height: 1.45,
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: const [
            _OverviewChip(label: 'Instant Credit'),
            _OverviewChip(label: 'Curated Packs'),
            _OverviewChip(label: 'Secure Checkout'),
          ],
        ),
      ],
    );
  }
}

class _OverviewIcon extends StatelessWidget {
  const _OverviewIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132.w,
      height: 132.w,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Image.asset(
          AppAssets.moneyBag,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
