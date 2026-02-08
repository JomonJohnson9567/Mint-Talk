import 'package:flutter/material.dart';
import 'package:mint_talk/core/transitions/models/screen_metadata.dart';
import 'package:mint_talk/core/transitions/widgets/animated_background_image.dart';
import 'package:mint_talk/core/transitions/widgets/animated_morphing_container.dart';

class AnimatedScreenWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final ScreenMetadata fromMetadata;
  final ScreenMetadata toMetadata;
  final Widget child;
  final bool isReverse;

  const AnimatedScreenWrapper({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.fromMetadata,
    required this.toMetadata,
    required this.child,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background color
        Positioned.fill(child: Container(color: toMetadata.backgroundColor)),

        // Animated Background/Top Images
        if (fromMetadata.backgroundImage != null ||
            toMetadata.backgroundImage != null)
          AnimatedBackgroundImage(
            animation: animation,
            oldImage: fromMetadata.backgroundImage,
            newImage: toMetadata.backgroundImage,
            isBackgroundImage: true,
            isReverse: isReverse,
          ),

        if (fromMetadata.topImage != null || toMetadata.topImage != null)
          AnimatedBackgroundImage(
            animation: animation,
            oldImage: fromMetadata.topImage,
            newImage: toMetadata.topImage,
            imageBottomPosition: toMetadata.imageBottomPosition,
            isBackgroundImage: false,
            isReverse: isReverse,
          ),

        // Animated Morphing Container with Content
        AnimatedMorphingContainer(
          animation: animation,
          fromBorderRadius: fromMetadata.borderRadius,
          toBorderRadius: toMetadata.borderRadius,
          isReverse: isReverse,
          child: child,
        ),
      ],
    );
  }
}
