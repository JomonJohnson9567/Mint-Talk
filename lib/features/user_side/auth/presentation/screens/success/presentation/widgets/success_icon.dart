// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/success/presentation/cubit/success_animation_cubit.dart';

class SuccessIcon extends StatelessWidget {
  const SuccessIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      onEnd: () => context.read<SuccessAnimationCubit>().startAnimation(),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: SizedBox(
        width: 200.w,
        height: 200.w,
        child: const Stack(
          alignment: Alignment.center,
          children: [_WaveEffect(), _BreathingIcon()],
        ),
      ),
    );
  }
}

class _WaveEffect extends StatelessWidget {
  const _WaveEffect();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuccessAnimationCubit, SuccessAnimationState>(
      // Only rebuild when wave cycle changes to restart the animation loop
      buildWhen: (previous, current) => previous.waveCycle != current.waveCycle,
      builder: (context, state) {
        return TweenAnimationBuilder<double>(
          key: ValueKey<int>(state.waveCycle), // Force restart on cycle change
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          onEnd: () => context.read<SuccessAnimationCubit>().loopWave(),
          builder: (context, value, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                _buildRing(value, 0.0),
                _buildRing(value, 0.33),
                _buildRing(value, 0.66),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRing(double progress, double delayOffset) {
    // Calculate effective progress for this specific ring (0.0 to 1.0 loop)
    final double ringProgress = (progress + delayOffset) % 1.0;

    // Scale: 1.0 (icon size) -> 1.8 (outer bound)
    final double scale = 1.0 + (ringProgress * 0.8);

    // Opacity: Fade out as it expands (0.3 -> 0.0)
    final double opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.3;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100.w,
        height: 100.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green.withOpacity(opacity),
        ),
      ),
    );
  }
}

class _BreathingIcon extends StatelessWidget {
  const _BreathingIcon();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuccessAnimationCubit, SuccessAnimationState>(
      // Only rebuild when expansion state changes
      buildWhen: (previous, current) =>
          previous.isExpanded != current.isExpanded,
      builder: (context, state) {
        return AnimatedScale(
          scale: state.isExpanded ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
          onEnd: () => context.read<SuccessAnimationCubit>().toggleBreathing(),
          child: Container(
            width: 100.w,
            height: 100.w,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: AppColors.white, size: 50.sp),
          ),
        );
      },
    );
  }
}
