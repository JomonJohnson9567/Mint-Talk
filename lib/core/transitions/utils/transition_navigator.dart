import 'package:flutter/material.dart';
import 'package:mint_talk/core/transitions/routes/morphing_page_route.dart';

class TransitionNavigator {
  /// Navigate to a new screen with morphing transition
  static Future<T?> pushWithTransition<T>({
    required BuildContext context,
    required Widget screen,
    required String toRoute,
    Duration? duration,
  }) {
    return Navigator.of(context).push<T>(
      MorphingPageRoute(
        child: screen,
        settings: RouteSettings(name: toRoute),
      ),
    );
  }

  /// Navigate to a named route with morphing transition
  static Future<T?> pushNamedWithTransition<T>({
    required BuildContext context,
    required String toRoute,
    required Widget Function() screenBuilder,
    Duration? duration,
  }) {
    return pushWithTransition<T>(
      context: context,
      screen: screenBuilder(),
      toRoute: toRoute,
      duration: duration,
    );
  }

  /// Replace current route with morphing transition
  static Future<T?> pushReplacementWithTransition<T, TO>({
    required BuildContext context,
    required Widget screen,
    required String toRoute,
    Duration? duration,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      MorphingPageRoute(
        child: screen,
        settings: RouteSettings(name: toRoute),
      ),
    );
  }
}
