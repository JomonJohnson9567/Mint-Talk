import 'package:flutter/material.dart';

/// Clips a rectangle with a soft wave along its top edge: the curve peaks
/// just left of centre and settles lower towards the right edge.
class WaveTopClipper extends CustomClipper<Path> {
  final double depth;

  const WaveTopClipper({required this.depth});

  @override
  Path getClip(Size size) {
    final w = size.width;
    return Path()
      ..moveTo(0, depth * 0.55)
      ..cubicTo(w * 0.18, depth * 0.05, w * 0.42, 0, w * 0.6, depth * 0.25)
      ..cubicTo(w * 0.78, depth * 0.5, w * 0.9, depth * 0.75, w, depth * 0.9)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(WaveTopClipper oldClipper) => oldClipper.depth != depth;
}
