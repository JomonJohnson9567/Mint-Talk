import 'package:flutter/material.dart';

class AnimatedBreathingGlow extends StatelessWidget {
  final bool isExpanded;
  final Widget child;
  final Duration duration;
  final double collapsedSize;
  final double expandedSize;
  final Color glowColor;
  final Color secondaryGlowColor;

  const AnimatedBreathingGlow({
    super.key,
    required this.isExpanded,
    required this.child,
    required this.glowColor,
    required this.secondaryGlowColor,
    this.duration = const Duration(milliseconds: 1400),
    this.collapsedSize = 150,
    this.expandedSize = 182,
  });

  @override
  Widget build(BuildContext context) {
    final haloSize = isExpanded ? expandedSize : collapsedSize;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          width: haloSize,
          height: haloSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                glowColor.withValues(alpha: isExpanded ? 0.28 : 0.18),
                secondaryGlowColor.withValues(alpha: isExpanded ? 0.14 : 0.08),
                Colors.transparent,
              ],
              stops: const [0.2, 0.6, 1],
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: isExpanded ? 0.30 : 0.18),
                blurRadius: isExpanded ? 42 : 26,
                spreadRadius: isExpanded ? 6 : 1,
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
