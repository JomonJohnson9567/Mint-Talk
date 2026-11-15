import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Lavender → cream page wash with two soft colour blobs near the top, so
/// the avatar sits in a glow instead of on a flat background.
class HostProfileBackground extends StatelessWidget {
  const HostProfileBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.videoCardBg,
            AppColors.popularCardBg,
            AppColors.homeBackground,
          ],
          stops: [0.0, 0.38, 0.72],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90.cw,
            right: -70.cw,
            child: _Blob(
              size: 260.cw,
              color: AppColors.lavenderBorder.withValues(alpha: 0.6),
            ),
          ),
          Positioned(
            top: 150.cw,
            left: -100.cw,
            child: _Blob(
              size: 240.cw,
              color: AppColors.pricePill.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
