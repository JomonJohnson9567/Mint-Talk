import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

import '../../data/models/recharge_plan_section.dart';
import 'recharge_plan_grid.dart';

class RechargePlanSectionWidget extends StatelessWidget {
  final RechargePlanSection section;

  const RechargePlanSectionWidget({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = _sectionAccentColor(section.title);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${section.plans.length} plans handpicked for quick recharge',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black.withValues(alpha: 0.58),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  _sectionBadge(section.title),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          RechargePlanGrid(
            plans: section.plans,
            accentColor: accentColor,
          ),
        ],
      ),
    );
  }
}

Color _sectionAccentColor(String title) {
  if (title == AppTexts.dhamakkaOffer) {
    return AppColors.orange;
  }

  if (title == AppTexts.specialOffer) {
    return AppColors.tealBackground;
  }

  return AppColors.primaryColor;
}

String _sectionBadge(String title) {
  if (title == AppTexts.dhamakkaOffer) {
    return 'High Value';
  }

  if (title == AppTexts.specialOffer) {
    return 'Featured';
  }

  return 'Popular';
}
