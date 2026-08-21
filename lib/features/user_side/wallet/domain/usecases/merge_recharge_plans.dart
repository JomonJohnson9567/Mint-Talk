import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

/// Merges API-sourced plans with the static fallback catalogue — API plans
/// first, deduplicated by id. Kept in the domain layer (rather than inline
/// in a cubit) so this business rule is testable on its own and reusable if
/// another screen ever needs the same merged plan list.
List<RechargePlanEntity> mergeRechargePlans({
  required List<RechargePlanEntity> apiPlans,
  required List<RechargePlanEntity> fallbackPlans,
}) {
  final merged = [...apiPlans, ...fallbackPlans];
  final uniqueMap = <String, RechargePlanEntity>{};
  for (final plan in merged) {
    uniqueMap[plan.id] = plan;
  }
  return uniqueMap.values.toList();
}
