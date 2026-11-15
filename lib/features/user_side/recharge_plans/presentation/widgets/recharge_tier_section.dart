import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/theme/plan_tier_theme.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/plan_tier.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

import 'recharge_plan_card.dart';
import 'recharge_plan_grid.dart';

/// One tier's header (medallion, pack name, count) and its grid of cards.
class RechargeTierSection extends StatelessWidget {
  const RechargeTierSection({
    super.key,
    required this.tier,
    required this.plans,
    required this.selectedPlanId,
    required this.onSelect,
  });

  final PlanTier tier;

  /// Non-empty, all of [tier], cheapest first.
  final List<RechargePlanEntity> plans;
  final String? selectedPlanId;
  final ValueChanged<RechargePlanEntity> onSelect;

  /// Tier plans share one name ("Gold Pack"), shown here instead of on each
  /// card; untiered plans keep their own names on the cards.
  String get _title {
    if (tier == PlanTier.other) return AppTexts.standardPackages;
    final name = plans.first.name?.trim();
    return (name != null && name.isNotEmpty) ? name : tier.name;
  }

  @override
  Widget build(BuildContext context) {
    final showName = tier == PlanTier.other;
    final hasBonus = plans.any((plan) => (plan.bonusPoints ?? 0) > 0);
    final hasName = showName &&
        plans.any((plan) => plan.name?.trim().isNotEmpty == true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TierHeader(
          theme: PlanTierTheme.of(tier),
          title: _title,
          count: plans.length,
        ),
        SizedBox(height: 10.cw),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              // A selected card scales up and glows past its cell.
              clipBehavior: Clip.none,
              itemCount: plans.length,
              gridDelegate: RechargePlanGrid.delegateFor(
                constraints.maxWidth,
                hasBonus: hasBonus,
                hasName: hasName,
              ),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return RechargePlanCard(
                  key: ValueKey(plan.id),
                  plan: plan,
                  showName: showName,
                  isSelected: plan.id == selectedPlanId,
                  onTap: () => onSelect(plan),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _TierHeader extends StatelessWidget {
  const _TierHeader({
    required this.theme,
    required this.title,
    required this.count,
  });

  final PlanTierTheme theme;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ExcludeSemantics(
          child: Container(
            width: 28.cw,
            height: 28.cw,
            decoration: BoxDecoration(
              gradient: theme.gradient,
              shape: BoxShape.circle,
              border: Border.all(color: theme.accent),
            ),
            child: Icon(theme.icon, size: 16.cw, color: theme.ink),
          ),
        ),
        SizedBox(width: 10.cw),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 16.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ),
        Text(
          '$count ${count == 1 ? AppTexts.packSuffix : AppTexts.packsSuffix}',
          style: TextStyle(
            fontSize: 12.csp,
            fontWeight: FontWeight.w700,
            color: AppColors.plumMuted,
          ),
        ),
      ],
    );
  }
}
