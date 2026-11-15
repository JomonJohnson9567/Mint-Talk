import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';

/// Pumps a minimal app and returns a context that sits under the root
/// Navigator's Overlay — the same overlay [showTopSnackBar] inserts into in
/// the real app.
Future<BuildContext> _pumpHost(
  WidgetTester tester, {
  Key? key,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  late BuildContext captured;
  await tester.pumpWidget(
    ScreenUtilInit(
      key: key,
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets(
    'a snackbar fired while no frames render (app backgrounded) does not '
    'leave an orphaned overlay entry that throws on resume',
    (tester) async {
      final context = await _pumpHost(tester);

      showTopSnackBar(context, 'Call ended');

      // pump(duration) advances the clock *before* drawing the next frame —
      // i.e. every timer showTopSnackBar scheduled gets to run while its
      // overlay entry has not been built yet. That is exactly what happens
      // on Android while the app is backgrounded: Dart timers keep firing,
      // but no frames are produced until the app resumes.
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);

      // On "resume" the message is actually shown, for its full duration.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Call ended'), findsOneWidget);
      expect(find.byType(TopSnackbar), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(TopSnackbar)).dy,
        greaterThanOrEqualTo(0),
      );

      // ...and then fully removed from the overlay.
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(find.byType(TopSnackbar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows, auto-dismisses and removes itself', (tester) async {
    final context = await _pumpHost(tester);

    showTopSnackBar(context, 'Hello');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Hello'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.byType(TopSnackbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a second message replaces the first in a single entry', (
    tester,
  ) async {
    final context = await _pumpHost(tester);

    showTopSnackBar(context, 'first');
    await tester.pump();
    showTopSnackBar(context, 'second');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(TopSnackbar), findsOneWidget);
    expect(find.text('second'), findsOneWidget);
    expect(find.text('first'), findsNothing);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.byType(TopSnackbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long real background (lifecycle paused, no frames) then resume',
    (tester) async {
      final context = await _pumpHost(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      showTopSnackBar(context, "The other participant's connection was lost");
      // Advances fake time without drawing any frame — far past every timer.
      await tester.binding.delayed(const Duration(seconds: 30));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(
        find.text("The other participant's connection was lost"),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(find.byType(TopSnackbar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('several messages while backgrounded collapse into one entry', (
    tester,
  ) async {
    final context = await _pumpHost(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    showTopSnackBar(context, 'Call ended');
    await tester.binding.delayed(const Duration(seconds: 5));
    showTopSnackBar(
      context,
      "Call ended: the caller's wallet balance ran out.",
    );
    await tester.binding.delayed(const Duration(seconds: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    expect(find.byType(TopSnackbar), findsOneWidget);
    expect(
      find.text("Call ended: the caller's wallet balance ran out."),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.byType(TopSnackbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'app tree replaced while a snackbar is up (overlay disposed) is safe',
    (tester) async {
      final first = await _pumpHost(tester, key: const ValueKey('a'));
      showTopSnackBar(first, 'old');
      await tester.pump();

      // Whole navigator/overlay torn down while the entry and its timers
      // are still alive (e.g. logout rebuilding the app).
      final second = await _pumpHost(tester, key: const ValueKey('b'));
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);

      showTopSnackBar(second, 'new');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('new'), findsOneWidget);
      expect(find.text('old'), findsNothing);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(find.byType(TopSnackbar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('an unmounted caller context falls back to the root overlay', (
    tester,
  ) async {
    if (!getIt.isRegistered<NavigationService>()) {
      getIt.registerSingleton<NavigationService>(NavigationService());
    }
    final navKey = getIt<NavigationService>().navigatorKey;
    await _pumpHost(tester, navigatorKey: navKey);

    late BuildContext pushedContext;
    navKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (context) {
          pushedContext = context;
          return const SizedBox();
        },
      ),
    );
    await tester.pumpAndSettle();
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(pushedContext.mounted, isFalse);

    showTopSnackBar(pushedContext, 'after pop');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    expect(find.text('after pop'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
    expect(find.byType(TopSnackbar), findsNothing);
  });
}
