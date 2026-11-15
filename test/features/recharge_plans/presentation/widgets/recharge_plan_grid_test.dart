// The plan cards have a fixed height, so the optional "+X bonus" line must
// still fit on small phones — selected (themed, check badge) or not. Plans
// are grouped into Silver / Gold / Platinum sections by their name.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_plan_card.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_plan_grid.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_tier_section.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/plan_tier.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

void main() {
  // Shaped like the live /plans response, already sorted by price.
  const plans = [
    RechargePlanEntity(id: 's1', name: 'Silver Pack', points: 1800, rawPrice: 49),
    RechargePlanEntity(id: 's2', name: 'Silver Pack', points: 3800, rawPrice: 99),
    RechargePlanEntity(id: 'g1', name: 'Gold Pack', points: 8000, rawPrice: 199),
    RechargePlanEntity(id: 'g2', name: 'Gold Pack', points: 16500, rawPrice: 399),
    RechargePlanEntity(
      id: 'p1',
      name: 'Platinum Pack',
      points: 44000,
      bonusPoints: 1000,
      rawPrice: 999,
    ),
    RechargePlanEntity(
      id: 'p2',
      name: 'Platinum Pack',
      points: 1500000,
      bonusPoints: 150000,
      rawPrice: 15000,
    ),
  ];

  Future<void> pumpGrid(
    WidgetTester tester, {
    Size screen = const Size(375, 812),
    double textScale = 1.0,
    String? selectedPlanId,
    ValueChanged<RechargePlanEntity>? onSelect,
    List<RechargePlanEntity> plans = plans,
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, child) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: RechargePlanGrid(
                plans: plans,
                selectedPlanId: selectedPlanId,
                onSelect: onSelect ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The test font (Ahem) has a 1.0 line height; the app's Manrope is ~1.37,
  // which is what overflowed the bonus card on a real device. A 1.4 text
  // scale approximates real metrics (and covers larger system fonts).
  for (final textScale in const [1.0, 1.4]) {
    for (final screen in const [
      Size(320, 568),
      Size(375, 812),
      Size(430, 932),
    ]) {
      testWidgets(
        'fits bonus lines without overflow at ${screen.width}pt, '
        'text scale $textScale',
        (tester) async {
          await pumpGrid(
            tester,
            screen: screen,
            textScale: textScale,
            selectedPlanId: 'p2',
          );

          expect(tester.takeException(), isNull);
          expect(find.text('+1,000 bonus'), findsOneWidget);
          expect(find.text('+1,50,000 bonus'), findsOneWidget);
        },
      );
    }
  }

  testWidgets('groups plans into Silver, Gold, Platinum sections in order', (
    tester,
  ) async {
    await pumpGrid(tester);

    final sections = tester
        .widgetList<RechargeTierSection>(find.byType(RechargeTierSection))
        .toList();
    expect(sections.map((s) => s.tier), [
      PlanTier.silver,
      PlanTier.gold,
      PlanTier.platinum,
    ]);
    expect(sections.map((s) => s.plans.map((p) => p.id).toList()), [
      ['s1', 's2'],
      ['g1', 'g2'],
      ['p1', 'p2'],
    ]);

    // Tier names live in the section header, once each — not on every card.
    expect(find.text('Silver Pack'), findsOneWidget);
    expect(find.text('Gold Pack'), findsOneWidget);
    expect(find.text('Platinum Pack'), findsOneWidget);
    expect(find.text('2 packs'), findsNWidgets(3));
  });

  testWidgets('untiered plans go in a trailing section with their names', (
    tester,
  ) async {
    await pumpGrid(
      tester,
      plans: const [
        RechargePlanEntity(id: 'x', name: 'Starter', points: 500, rawPrice: 9),
        RechargePlanEntity(id: 'g', name: 'Gold Pack', points: 8000, rawPrice: 199),
      ],
    );

    final tiers = tester
        .widgetList<RechargeTierSection>(find.byType(RechargeTierSection))
        .map((s) => s.tier);
    expect(tiers, [PlanTier.gold, PlanTier.other]);
    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('1 pack'), findsNWidgets(2));
  });

  testWidgets('tapping a card reports it and only that card is selected', (
    tester,
  ) async {
    RechargePlanEntity? tapped;
    await pumpGrid(tester, selectedPlanId: 'g1', onSelect: (p) => tapped = p);

    final cards = tester
        .widgetList<RechargePlanCard>(find.byType(RechargePlanCard))
        .where((card) => card.isSelected)
        .map((card) => card.plan.id);
    expect(cards, ['g1']);

    await tester.tap(find.text('16,500'));
    expect(tapped?.id, 'g2');
  });
}
