/// Category a recharge plan belongs to. The plans API has no dedicated field
/// for it — the tier is carried in the plan name ("Silver Pack", "Gold Pack",
/// "Platinum Pack"), so it is derived from [RechargePlanEntity.name].
///
/// Declared cheapest → most premium; the recharge screen shows sections in
/// this order, with [other] (unnamed / unrecognised plans) last.
enum PlanTier {
  silver,
  gold,
  platinum,
  other;

  static PlanTier fromName(String? name) {
    final normalized = name?.trim().toLowerCase() ?? '';
    if (normalized.contains('platinum')) return PlanTier.platinum;
    if (normalized.contains('gold')) return PlanTier.gold;
    if (normalized.contains('silver')) return PlanTier.silver;
    return PlanTier.other;
  }
}
