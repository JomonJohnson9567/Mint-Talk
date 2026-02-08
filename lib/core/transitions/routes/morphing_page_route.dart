import 'package:flutter/material.dart';

/// Simple morphing page route that creates smooth transitions
class MorphingPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  MorphingPageRoute({required this.child, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Pure Fade transition for the page content reduces layout shifts
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));

          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      );
}
