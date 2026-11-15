import 'package:flutter/material.dart';

/// Shows [child] at its natural size when it fits the height it's given,
/// and scales it down uniformly when it doesn't (never up). [child] is laid
/// out at the full available width with unbounded height, so it must size
/// itself vertically, e.g. a `Column` with `MainAxisSize.min`.
///
/// The call screens size everything off the screen width (`.cw`), so a
/// short window, such as split-screen or a landscape phone, keeps
/// full-size controls with too little height for them. Scaling keeps those
/// controls usable rather than overflowing.
class ScaleDownToFit extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const ScaleDownToFit({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: SizedBox(width: constraints.maxWidth, child: child),
      ),
    );
  }
}

/// Fills the space it's given with [middle] above [bottom], with [bottom]
/// (the call controls) getting space first. [bottom] keeps its natural size
/// and sits at the bottom edge when it fits, or scales down to the whole
/// height when it doesn't. [middle] fills whatever is left, which can be
/// nothing in a very short window, so wrap it in [ScaleDownToFit] unless it
/// already adapts to its height.
class CallControlsFirstLayout extends StatelessWidget {
  final Widget middle;
  final Widget bottom;

  const CallControlsFirstLayout({
    super.key,
    required this.middle,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Expanded(child: middle),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: ScaleDownToFit(
              alignment: Alignment.bottomCenter,
              child: bottom,
            ),
          ),
        ],
      ),
    );
  }
}
