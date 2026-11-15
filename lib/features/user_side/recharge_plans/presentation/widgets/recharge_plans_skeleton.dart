import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

import 'recharge_plan_grid.dart';

/// Skeleton loading placeholder for the tiered plan grid in [ScreenContents]
/// while [WalletCubit] fetches plans: two sections, each a header bar and a
/// row of tiles sized like the real cards.
class RechargePlansSkeleton extends StatelessWidget {
  const RechargePlansSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final delegate = RechargePlanGrid.delegateFor(constraints.maxWidth);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var section = 0; section < 2; section++) ...[
                if (section > 0)
                  SizedBox(height: RechargePlanGrid.sectionSpacing),
                Row(
                  children: [
                    SkeletonBox(
                      width: 28.cw,
                      height: 28.cw,
                      shape: BoxShape.circle,
                    ),
                    SizedBox(width: 10.cw),
                    SkeletonBox(
                      width: 110.cw,
                      height: 16.cw,
                      borderRadius: BorderRadius.circular(6.cw),
                    ),
                  ],
                ),
                SizedBox(height: 10.cw),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: 3,
                  gridDelegate: delegate,
                  itemBuilder: (context, index) =>
                      SkeletonBox(borderRadius: BorderRadius.circular(16.cw)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
