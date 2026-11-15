import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/payment_method_sheet.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/payment_method.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

void main() {
  const plan = RechargePlanEntity(id: 'p1', points: 85000, rawPrice: 1000);

  // Opens the sheet from a button and records what show() completes with.
  Future<List<PaymentMethod?>> openSheet(WidgetTester tester) async {
    final results = <PaymentMethod?>[];

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    results.add(await PaymentMethodSheet.show(context, plan)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('lists UPI, cards and net banking for the plan', (tester) async {
    await openSheet(tester);

    expect(find.text('Choose payment method'), findsOneWidget);
    expect(find.text('Paying ₹ 1,000 for 85,000 coins'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('Cards'), findsOneWidget);
    expect(find.text('Net banking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completes with the tapped method', (tester) async {
    final results = await openSheet(tester);

    await tester.tap(find.text('Net banking'));
    await tester.pumpAndSettle();

    expect(results, [PaymentMethod.netbanking]);
    expect(find.text('Choose payment method'), findsNothing);
  });

  testWidgets('completes with null when dismissed', (tester) async {
    final results = await openSheet(tester);

    await tester.tapAt(const Offset(10, 10)); // the barrier above the sheet
    await tester.pumpAndSettle();

    expect(results, [null]);
  });
}
