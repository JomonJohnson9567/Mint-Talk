import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// The headset mascot shown in place of the other participant's photo.
///
/// The mascot PNG has an opaque square background, so its edges are masked
/// out radially to melt into the screen's cream background. While the call
/// is still being set up the mascot gently floats; it rests once connected.
class AudioCallMascot extends StatefulWidget {
  final bool isFloating;
  final String asset;

  const AudioCallMascot({
    super.key,
    required this.isFloating,
    this.asset = AppAssets.applyHostMascot,
  });

  @override
  State<AudioCallMascot> createState() => _AudioCallMascotState();
}

class _AudioCallMascotState extends State<AudioCallMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AudioCallMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFloating != widget.isFloating) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.isFloating) {
      _controller.repeat();
    } else {
      // Settle back to the resting position instead of freezing mid-float.
      _controller.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final floatDistance = 8.cw;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          -floatDistance * math.sin(_controller.value * math.pi).abs(),
        ),
        child: child,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const RadialGradient(
            colors: [AppColors.black, AppColors.black, AppColors.transparent],
            // Radius spans centre → mid-edge; the mascot and cushion reach
            // ~0.8 of it, so only the scenery beyond that is faded.
            stops: [0.0, 0.8, 1.0],
          ).createShader(bounds),
          child: Image.asset(widget.asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
