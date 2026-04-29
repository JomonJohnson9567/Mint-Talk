import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/recharge_plan_item.dart';
import 'recharge_plan_card.dart';

class RechargePlanGrid extends StatelessWidget {
  final List<RechargePlanItem> plans;
  final Color accentColor;

  const RechargePlanGrid({
    super.key,
    required this.plans,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 680
            ? 3
            : width >= 360
            ? 2
            : 1;
        final horizontalSpacing = width >= 680 ? 16.0 : 12.0;
        final verticalSpacing = width >= 680 ? 16.0 : 12.0;
        final tileHeight = width >= 680
            ? 248.0
            : width >= 360
            ? 228.0
            : 212.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: plans.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: horizontalSpacing.w,
            mainAxisSpacing: verticalSpacing.h,
            mainAxisExtent: tileHeight.h,
          ),
          itemBuilder: (context, index) {
            return RechargePlanCard(
              plan: plans[index],
              accentColor: accentColor,
            );
          },
        );
      },
    );
  }
}
