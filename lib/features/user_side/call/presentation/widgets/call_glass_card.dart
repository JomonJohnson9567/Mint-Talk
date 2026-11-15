import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// The rounded card the call controls sit on.
///
/// Light: frosted white over the cream audio/ended backdrop. Dark: a
/// translucent plum over the video feed — deliberately without a
/// [BackdropFilter], which is costly and unreliable on top of Agora's native
/// video platform view.
class CallGlassCard extends StatelessWidget {
  final Widget child;
  final bool dark;

  const CallGlassCard({super.key, required this.child, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(28.cw);
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.cw, 18.cw, 12.cw, 16.cw),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.callGlassDark.withValues(alpha: 0.55)
            : AppColors.white.withValues(alpha: 0.6),
        borderRadius: radius,
        border: Border.all(
          color: AppColors.white.withValues(alpha: dark ? 0.16 : 0.85),
          width: 1.2,
        ),
      ),
      child: child,
    );

    if (dark) return card;

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: card,
      ),
    );
  }
}
