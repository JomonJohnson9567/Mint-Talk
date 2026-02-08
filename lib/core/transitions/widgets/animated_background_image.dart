import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedBackgroundImage extends StatelessWidget {
  final Animation<double> animation;
  final String? oldImage;
  final String? newImage;
  final double? imageBottomPosition;
  final bool isBackgroundImage;
  final bool isReverse;

  const AnimatedBackgroundImage({
    super.key,
    required this.animation,
    this.oldImage,
    this.newImage,
    this.imageBottomPosition,
    this.isBackgroundImage = false,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final slideAnimation =
            Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
              ),
            );

        final newSlideAnimation =
            Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
              ),
            );

        final fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

        final fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        );

        return Stack(
          children: [
            // Old Image - Slides out to left
            if (oldImage != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: isBackgroundImage ? 0 : imageBottomPosition ?? 280.h,
                top: isBackgroundImage ? 0 : null,
                child: SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeOutAnimation,
                    child: _buildImage(oldImage!, isBackgroundImage),
                  ),
                ),
              ),
            // New Image - Slides in from right
            if (newImage != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: isBackgroundImage ? 0 : imageBottomPosition ?? 280.h,
                top: isBackgroundImage ? 0 : null,
                child: SlideTransition(
                  position: newSlideAnimation,
                  child: FadeTransition(
                    opacity: fadeInAnimation,
                    child: _buildImage(newImage!, isBackgroundImage),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImage(String imagePath, bool isBackground) {
    if (isBackground) {
      return Align(
        alignment: Alignment.topCenter,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      );
    } else {
      return Center(child: Image.asset(imagePath, fit: BoxFit.contain));
    }
  }
}
