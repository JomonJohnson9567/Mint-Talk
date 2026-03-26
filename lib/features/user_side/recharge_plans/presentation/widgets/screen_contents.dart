import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/models/recharge_plan_data.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_plan_section_widget.dart';

class ScreenContents extends StatelessWidget {
  const ScreenContents({
    super.key,
    required this.contentWidth,
  });

  final double contentWidth;

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _RechargeOverviewCard(),
                  SizedBox(height: 18.h),
                  for (var index = 0;
                      index < RechargePlanData.sections.length;
                      index++) ...[
                    RechargePlanSectionWidget(
                      section: RechargePlanData.sections[index],
                    ),
                    if (index != RechargePlanData.sections.length - 1)
                      SizedBox(height: 18.h),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
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
