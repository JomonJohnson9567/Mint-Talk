import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Three pulsing dots signalling that the call is still being set up.
/// Drives its own animation — the cubit's `waveStep` is never emitted.
class AnimatedDots extends StatefulWidget {
  final Color color;

  const AnimatedDots({super.key, this.color = AppColors.plumDeep});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = 10.cw;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Each dot peaks a third of a cycle after the previous one.
            final phase = (_controller.value - index / 3) * 2 * math.pi;
            final pulse = (math.sin(phase) + 1) / 2;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.cw),
              child: Opacity(
                opacity: 0.35 + 0.65 * pulse,
                child: Transform.scale(
                  scale: 0.8 + 0.2 * pulse,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
