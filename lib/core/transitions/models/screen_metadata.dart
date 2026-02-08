import 'package:flutter/material.dart';

/// Metadata for each screen to define transition properties
class ScreenMetadata {
  final String? backgroundImage;
  final String? topImage;
  final double borderRadius;
  final double? imageBottomPosition;
  final Color backgroundColor;

  const ScreenMetadata({
    this.backgroundImage,
    this.topImage,
    required this.borderRadius,
    this.imageBottomPosition,
    required this.backgroundColor,
  });
}
