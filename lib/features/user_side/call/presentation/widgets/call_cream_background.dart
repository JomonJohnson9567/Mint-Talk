import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Cream fill with a few soft lavender and peach glows, echoing the
/// mascot artwork's own backdrop. Shared by the audio call screen and the
/// post-call screen of both call types.
class CallCreamBackground extends StatelessWidget {
  const CallCreamBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.creamBackground,
      child: Stack(
        children: [
          _glow(
            top: -60.cw,
            left: -80.cw,
            size: 260.cw,
            color: AppColors.lavenderBorder,
          ),
          _glow(
            top: 160.cw,
            right: -110.cw,
            size: 280.cw,
            color: AppColors.pricePill,
          ),
          _glow(
            bottom: 60.cw,
            left: -120.cw,
            size: 300.cw,
            color: AppColors.lavenderBorder,
          ),
        ],
      ),
    );
  }

  Widget _glow({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.55), color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
