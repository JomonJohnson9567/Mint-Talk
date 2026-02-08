import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom flight shuttle builder for morphing container transitions
Widget morphingContainerFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero toHero = toHeroContext.widget as Hero;
  final Hero fromHero = fromHeroContext.widget as Hero;

  // Get the actual widgets
  final Widget toChild = toHero.child;
  final Widget fromChild = fromHero.child;

  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      // Slide down animation (0 to 20 pixels)
      final slideValue = Tween<double>(begin: 0.0, end: 20.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      );

      // Content crossfade
      final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        ),
      );

      final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        ),
      );

      return Transform.translate(
        offset: Offset(0, slideValue.value),
        child: Stack(
          children: [
            // Fade out old content
            Opacity(opacity: fadeOut.value, child: fromChild),
            // Fade in new content
            Opacity(opacity: fadeIn.value, child: toChild),
          ],
        ),
      );
    },
  );
}

/// Custom flight shuttle builder for image transitions
Widget morphingImageFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  final Hero toHero = toHeroContext.widget as Hero;
  final Hero fromHero = fromHeroContext.widget as Hero;

  // Determine slide direction based on flight direction
  // Push: Slide Left (Next image comes from Right)
  // Pop: Slide Right (Previous image comes from Left)
  var isPush = flightDirection == HeroFlightDirection.push;

  // Fallback: sometimes on the initial push the reported flightDirection
  // can be unreliable. Infer direction from the global X positions of
  // the from/to Hero render boxes when available.
  try {
    final fromRender = fromHeroContext.findRenderObject();
    final toRender = toHeroContext.findRenderObject();
    if (fromRender is RenderBox && toRender is RenderBox) {
      if (fromRender.hasSize &&
          toRender.hasSize &&
          fromRender.attached &&
          toRender.attached) {
        final fromGlobal = fromRender.localToGlobal(Offset.zero);
        final toGlobal = toRender.localToGlobal(Offset.zero);
        // If destination is positioned to the right of source, we want
        // the new image to come from right -> left (i.e. a push)
        isPush = (toGlobal.dx > fromGlobal.dx) || isPush;

        if (kDebugMode) {
          debugPrint(
            'morphingImageFlightShuttle: flightDirection=$flightDirection',
          );
          debugPrint(
            'morphingImageFlightShuttle: from.dx=${fromGlobal.dx}, to.dx=${toGlobal.dx}, inferredIsPush=$isPush',
          );
        }
      }
    }
  } catch (_) {
    // ignore errors and fall back to reported flightDirection
  }

  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      // Slide animations - Simultaneous movement
      final slideOutAnimation =
          Tween<Offset>(
            begin: Offset.zero,
            end: isPush ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0),
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
            ),
          );

      final slideInAnimation =
          Tween<Offset>(
            begin: isPush ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
            ),
          );

      return Stack(
        clipBehavior:
            Clip.none, // Allow sliding images to be seen outside bounds
        children: [
          // Old image continues to be visible as it slides out
          SlideTransition(position: slideOutAnimation, child: fromHero.child),
          // New image is visible as it slides in
          SlideTransition(position: slideInAnimation, child: toHero.child),
        ],
      );
    },
  );
}
