import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

/// Progress through the required fields. Finished steps fill solid plum, the
/// step the user is on glows in a lighter tint (so step 1 isn't an empty
/// bar), and a soft shine sweeps across the lit part until everything's done.
class ProfileProgressBar extends StatefulWidget {
  const ProfileProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  @override
  State<ProfileProgressBar> createState() => _ProfileProgressBarState();
}

class _ProfileProgressBarState extends State<ProfileProgressBar>
    with SingleTickerProviderStateMixin {
  static const _fillDuration = Duration(milliseconds: 550);
  static const _fillCurve = Curves.easeOutCubic;

  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool get _isDone => widget.completed >= widget.total;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncShine();
  }

  @override
  void didUpdateWidget(covariant ProfileProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncShine();
  }

  /// Shine runs only while there's something left to do, and never with the
  /// OS "reduce motion" setting on.
  void _syncShine() {
    final shouldRun = !_isDone && !MediaQuery.disableAnimationsOf(context);
    if (shouldRun && !_shine.isAnimating) {
      _shine.repeat();
    } else if (!shouldRun && _shine.isAnimating) {
      _shine.stop();
      _shine.value = 0;
    }
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.total;
    final completed = widget.completed.clamp(0, total);
    // The current step is lit too, so the bar is never blank.
    final reached = _isDone ? total : completed + 1;
    final step = reached.clamp(1, total);
    final radius = BorderRadius.circular(99.r);

    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: AppTexts.stepOf(step, total),
            child: ClipRRect(
              borderRadius: radius,
              child: Container(
                height: 10.h,
                color: AppColors.lavenderBorder.withValues(alpha: 0.55),
                child: Stack(
                  children: [
                    // Current step: lighter glow.
                    _AnimatedFill(
                      fraction: reached / total,
                      duration: _fillDuration,
                      curve: _fillCurve,
                      radius: radius,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withValues(alpha: 0.35),
                          AppColors.linkMagenta.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                    // Finished steps: solid plum.
                    _AnimatedFill(
                      fraction: completed / total,
                      duration: _fillDuration,
                      curve: _fillCurve,
                      radius: radius,
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryColor, AppColors.linkMagenta],
                      ),
                    ),
                    // Shine sweeping across the lit part.
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: reached / total),
                      duration: _fillDuration,
                      curve: _fillCurve,
                      builder: (context, fraction, _) => FractionallySizedBox(
                        widthFactor: fraction,
                        heightFactor: 1,
                        child: AnimatedBuilder(
                          animation: _shine,
                          builder: (context, _) => _isDone
                              ? const SizedBox.shrink()
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.white.withValues(alpha: 0),
                                        AppColors.white.withValues(alpha: 0.55),
                                        AppColors.white.withValues(alpha: 0),
                                      ],
                                      stops: const [0.35, 0.5, 0.65],
                                      transform: _SlideGradient(
                                        // -1 → 1 so the band enters and exits
                                        // fully off each edge.
                                        _shine.value * 2 - 1,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _isDone
              ? Icon(
                  Icons.check_circle_rounded,
                  key: const ValueKey('done'),
                  size: 18.sp,
                  color: AppColors.onlineIndicator,
                )
              : Text(
                  AppTexts.stepOf(step, total),
                  key: ValueKey(step),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumMuted,
                  ),
                ),
        ),
      ],
    );
  }
}

class _AnimatedFill extends StatelessWidget {
  const _AnimatedFill({
    required this.fraction,
    required this.duration,
    required this.curve,
    required this.radius,
    required this.gradient,
  });

  final double fraction;
  final Duration duration;
  final Curve curve;
  final BorderRadius radius;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: fraction),
      duration: duration,
      curve: curve,
      builder: (context, value, _) => FractionallySizedBox(
        widthFactor: value,
        heightFactor: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
        ),
      ),
    );
  }
}

/// Shifts a gradient horizontally by [offset] × its width.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.offset);

  final double offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * offset, 0, 0);
}
