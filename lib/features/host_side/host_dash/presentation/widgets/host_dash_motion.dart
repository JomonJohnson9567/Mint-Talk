import 'package:flutter/material.dart';

/// Shared timing for the idle ⇄ online dashboard morph, so every section
/// (header, call card, hosts strip, promo) moves as one motion.
const Duration kHostDashMorphDuration = Duration(milliseconds: 450);
const Curve kHostDashMorphCurve = Curves.easeInOutCubic;

Duration _morphDuration(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context)
    ? Duration.zero
    : kHostDashMorphDuration;

/// Swaps between keyed children with a sequenced cross-fade while the
/// height morphs: the outgoing child is gone by the halfway point and the
/// incoming one fades/slides in as the layout settles.
class HostDashSwitcher extends StatelessWidget {
  final Widget child;

  const HostDashSwitcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final duration = _morphDuration(context);

    return AnimatedSize(
      duration: duration,
      curve: kHostDashMorphCurve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
        switchOutCurve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        // Only the incoming child sizes the stack; outgoing children are
        // pinned to the top so AnimatedSize can morph old → new height.
        layoutBuilder: (currentChild, previousChildren) => Stack(
          alignment: Alignment.topCenter,
          children: [
            for (final previous in previousChildren)
              Positioned(top: 0, left: 0, right: 0, child: previous),
            ?currentChild,
          ],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(animation),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Fades [child] while collapsing it toward the top (and the reverse), so
/// the widgets below glide up instead of jumping.
class HostDashCollapsible extends StatelessWidget {
  final bool visible;
  final Widget child;

  const HostDashCollapsible({
    super.key,
    required this.visible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _morphDuration(context),
      switchInCurve: kHostDashMorphCurve,
      switchOutCurve: kHostDashMorphCurve,
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topCenter,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: visible
          ? KeyedSubtree(key: const ValueKey('shown'), child: child)
          : const SizedBox(key: ValueKey('hidden'), width: double.infinity),
    );
  }
}
