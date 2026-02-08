import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class AnimatedMorphingContainer extends StatelessWidget {
  final Animation<double> animation;
  final double fromBorderRadius;
  final double toBorderRadius;
  final Widget child;
  final bool isReverse;

  const AnimatedMorphingContainer({
    super.key,
    required this.animation,
    required this.fromBorderRadius,
    required this.toBorderRadius,
    required this.child,
    this.isReverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        // Container slides down slightly (0 to 20 pixels)
        final slideDownAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
          ),
        );

        // Border radius morphs
        final borderRadiusAnimation =
            Tween<double>(begin: fromBorderRadius, end: toBorderRadius).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
              ),
            );

        // Content fades in
        final contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
              ),
            );

        return Transform.translate(
          offset: Offset(0, slideDownAnimation.value),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(borderRadiusAnimation.value.r),
                ),
              ),
              child: FadeTransition(
                opacity: contentFadeAnimation,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
