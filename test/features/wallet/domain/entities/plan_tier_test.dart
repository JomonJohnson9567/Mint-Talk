import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/plan_tier.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

void main() {
  group('PlanTier.fromName', () {
    test('reads the tier from the API plan name', () {
      expect(PlanTier.fromName('Silver Pack'), PlanTier.silver);
      expect(PlanTier.fromName('Gold Pack'), PlanTier.gold);
      expect(PlanTier.fromName('Platinum Pack'), PlanTier.platinum);
    });

    test('ignores case and surrounding whitespace', () {
      expect(PlanTier.fromName('GOLD pack'), PlanTier.gold);
      expect(PlanTier.fromName('  Platinum Pack  '), PlanTier.platinum);
    });

    test('falls back to other for missing or unknown names', () {
      expect(PlanTier.fromName(null), PlanTier.other);
      expect(PlanTier.fromName(''), PlanTier.other);
      expect(PlanTier.fromName('Starter'), PlanTier.other);
    });
  });

  test('RechargePlanEntity.tier derives from name', () {
    const plan = RechargePlanEntity(id: 'a', name: 'Gold Pack');
    expect(plan.tier, PlanTier.gold);
    expect(const RechargePlanEntity(id: 'b').tier, PlanTier.other);
  });
}
