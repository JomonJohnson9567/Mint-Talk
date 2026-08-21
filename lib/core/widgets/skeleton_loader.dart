import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// One shimmer "bone" — a flat placeholder box. Wrap a whole skeleton
/// layout in a single [SkeletonShimmer] (not each box individually) so the
/// animated sweep runs off one shared `AnimationController` instead of one
/// per bone.
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
    this.padding,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(8)),
        color: const Color(0xFFEAEEF4),
      ),
      child: child,
    );
  }
}

/// Wraps an entire skeleton layout (built from one or more [SkeletonBox]es)
/// in a single animated shimmer sweep.
class SkeletonShimmer extends StatelessWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEAEEF4),
      highlightColor: const Color(0xFFF7FAFC),
      child: child,
    );
  }
}
