import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';

/// Soft translucent circle used to decorate the corners of plum cards.
class PlumBlob extends StatelessWidget {
  const PlumBlob({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.linkMagenta.withValues(alpha: 0.2),
      ),
    );
  }
}
