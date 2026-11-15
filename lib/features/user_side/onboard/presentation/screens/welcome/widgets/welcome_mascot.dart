import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';

/// The waving mascot standing on a peach-and-lavender backdrop.
class WelcomeMascot extends StatelessWidget {
  const WelcomeMascot({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Clipped so the backdrop never paints over the logo or headline.
        const ClipRect(child: CustomPaint(painter: _WelcomeBackdropPainter())),
        Padding(
          padding: EdgeInsets.fromLTRB(36.w, 10.h, 36.w, 6.h),
          child: Hero(
            tag: 'morphing_image',
            flightShuttleBuilder: morphingImageFlightShuttleBuilder,
            child: Image.asset(AppAssets.welcomeMascot, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}

class _WelcomeBackdropPainter extends CustomPainter {
  const _WelcomeBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Large peach sun bleeding off the upper-left edge, sized by whichever
    // side is tighter so its top stays just below the tagline.
    final sunRadius = math.min(w * 0.42, h * 0.46);
    canvas.drawCircle(
      Offset(w * 0.18, h * 0.04 + sunRadius),
      sunRadius,
      Paint()..color = AppColors.greetingBanner,
    );

    // Lavender hills rolling behind the mascot.
    final hills = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(w * 0.28, h * 0.4, w * 0.62, h * 0.66, w, h * 0.42)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hills, Paint()..color = AppColors.welcomeHill);

    // Cream ground the mascot stands on, blending into the page.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 1.04),
        width: w * 1.5,
        height: h * 0.5,
      ),
      Paint()..color = AppColors.creamBackground,
    );

    _drawSparkle(canvas, Offset(w * 0.09, h * 0.2), 9, AppColors.audioAccent);
    _drawSparkle(
      canvas,
      Offset(w * 0.12, h * 0.74),
      7,
      AppColors.audioAccent.withAlpha(170),
    );
    _drawSparkle(
      canvas,
      Offset(w * 0.87, h * 0.34),
      8,
      AppColors.lavenderBorder,
    );
  }

  /// Four-point star with pinched sides.
  void _drawSparkle(Canvas canvas, Offset c, double r, Color color) {
    final pinch = r * 0.28;
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + pinch, c.dy - pinch, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + pinch, c.dy + pinch, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - pinch, c.dy + pinch, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - pinch, c.dy - pinch, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WelcomeBackdropPainter oldDelegate) => false;
}
