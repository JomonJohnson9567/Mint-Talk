import 'package:flutter/material.dart';

/// Paints a bright band chasing around [child]'s rounded-rect edge to signal
/// "live" — used on the waiting-for-call card while the host is online.
///
/// [child] is isolated inside its own [RepaintBoundary] so the animation
/// (driven by a single [AnimationController]) only ever repaints the thin
/// border layer on top of it, never the comparatively expensive
/// gradient/shadow content underneath. `StatefulWidget` is used here only
/// because it owns that controller — everything else in this feature stays
/// stateless per project convention.
class PulsingOnlineBorder extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double strokeWidth;
  final Color color;
  final Duration duration;

  const PulsingOnlineBorder({
    super.key,
    required this.child,
    required this.borderRadius,
    this.strokeWidth = 2.5,
    this.color = const Color(0xFF1FE64A),
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<PulsingOnlineBorder> createState() => _PulsingOnlineBorderState();
}

class _PulsingOnlineBorderState extends State<PulsingOnlineBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(child: widget.child),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _ChasingBorderPainter(
                  progress: _controller.value,
                  radius: widget.borderRadius,
                  strokeWidth: widget.strokeWidth,
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChasingBorderPainter extends CustomPainter {
  final double progress;
  final double radius;
  final double strokeWidth;
  final Color color;

  const _ChasingBorderPainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect bounds = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      bounds.deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.95),
          color.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * 6.283185307179586),
      ).createShader(bounds);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _ChasingBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
