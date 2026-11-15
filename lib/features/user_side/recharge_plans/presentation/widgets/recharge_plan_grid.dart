import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/plan_tier.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

import 'recharge_tier_section.dart';

/// The plan catalogue grouped into one section per [PlanTier] — Silver, Gold,
/// Platinum, then any untiered plans — each a grid of selectable cards.
class RechargePlanGrid extends StatelessWidget {
  /// Sorted by price, cheapest first (see `WalletCubit.fetchPlans`); that
  /// order is kept inside each section.
  final List<RechargePlanEntity> plans;
  final String? selectedPlanId;
  final ValueChanged<RechargePlanEntity> onSelect;

  const RechargePlanGrid({
    super.key,
    required this.plans,
    required this.selectedPlanId,
    required this.onSelect,
  });

  /// Shared with [RechargePlansSkeleton] so loading tiles match the grid.
  /// [hasBonus] adds room for the "+X bonus" line so every row stays the
  /// same height; without bonuses the grid matches the design exactly.
  /// [hasName] adds room for the package-name line above the coin.
  static SliverGridDelegate delegateFor(
    double width, {
    bool hasBonus = false,
    bool hasName = false,
  }) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: width >= 600 ? 4 : 3,
      crossAxisSpacing: 8.cw,
      mainAxisSpacing: 8.cw,
      mainAxisExtent: ((hasBonus ? 172 : 152) + (hasName ? 18 : 0)).cw,
    );
  }

  /// Spacing between tier sections; shared with the skeleton.
  static double get sectionSpacing => 20.cw;

  @override
  Widget build(BuildContext context) {
    final byTier = <PlanTier, List<RechargePlanEntity>>{};
    for (final plan in plans) {
      byTier.putIfAbsent(plan.tier, () => []).add(plan);
    }

    final sections = [
      for (final tier in PlanTier.values)
        if (byTier[tier] case final tierPlans?)
          RechargeTierSection(
            key: ValueKey(tier),
            tier: tier,
            plans: tierPlans,
            selectedPlanId: selectedPlanId,
            onSelect: onSelect,
          ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) SizedBox(height: sectionSpacing),
          sections[i],
        ],
      ],
    );
  }
}
