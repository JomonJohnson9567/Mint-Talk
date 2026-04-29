import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/screen/plan_detail_screen.dart';

import '../../data/models/recharge_plan_item.dart';

class RechargePlanCard extends StatelessWidget {
  final RechargePlanItem plan;
  final Color accentColor;

  const RechargePlanCard({
    super.key,
    required this.plan,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.planDetail,
          arguments: PlanDetailArgs(plan: plan, accentColor: accentColor),
        );
      },
      borderRadius: BorderRadius.circular(22.r),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 160;
          final hasTightHeight = constraints.maxHeight < 232;
          final imageContainerSize = (isCompact || hasTightHeight) ? 52.0 : 60.0;
          final imageSize = (isCompact || hasTightHeight) ? 30.0 : 40.0;
          final coinFontSize = (isCompact || hasTightHeight) ? 16.0 : 18.0;
          final priceFontSize = (isCompact || hasTightHeight) ? 18.0 : 20.0;
          final badgeFontSize = isCompact ? 8.0 : 9.0;
          final contentPadding = hasTightHeight ? 10.0 : 12.0;
          final topSpacing = hasTightHeight ? 4.0 : 6.0;
          final iconSpacing = hasTightHeight ? 8.0 : 10.0;
          final bottomSpacing = hasTightHeight ? 6.0 : 8.0;
          final badgeHeight = hasTightHeight ? 22.0 : 24.0;
          final bottomPanelVerticalPadding = hasTightHeight ? 7.0 : 8.0;
          final iconPadding = hasTightHeight ? 8.0 : 10.0;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  accentColor.withValues(
                    alpha: plan.badgeText == null ? 0.04 : 0.1,
                  ),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: _PlanBadge(
                      text: plan.badgeText,
                      fontSize: badgeFontSize,
                      backgroundColor: accentColor,
                      reservedHeight: badgeHeight,
                    ),
                  ),
                  SizedBox(height: topSpacing),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: imageContainerSize,
                            height: imageContainerSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentColor.withValues(alpha: 0.12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(iconPadding),
                              child: Image.asset(
                                AppAssets.moneyBag,
                                height: imageSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: iconSpacing),
                        Text(
                          plan.coins,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: coinFontSize.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AppTexts.coinsSuffix,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black.withValues(alpha: 0.52),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: bottomSpacing),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: bottomPanelVerticalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.76),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.12),
                      ),
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${AppTexts.rupeeSymbol} ',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: plan.price,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: priceFontSize.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String? text;
  final double fontSize;
  final Color backgroundColor;
  final double reservedHeight;

  const _PlanBadge({
    this.text,
    required this.fontSize,
    required this.backgroundColor,
    required this.reservedHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return SizedBox(height: reservedHeight);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: reservedHeight),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text!,
          style: TextStyle(
            color: AppColors.white,
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
