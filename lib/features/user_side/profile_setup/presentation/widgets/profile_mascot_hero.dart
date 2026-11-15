import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';

/// Mascot that bobs gently, squash-bounces when tapped and talks the user
/// through the form via a speech bubble above it.
class ProfileMascotHero extends StatefulWidget {
  const ProfileMascotHero({super.key, required this.message});

  /// Swapped with a fade/scale whenever it changes.
  final String message;

  @override
  State<ProfileMascotHero> createState() => _ProfileMascotHeroState();
}

class _ProfileMascotHeroState extends State<ProfileMascotHero>
    with TickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _float.stop();
    } else if (!_float.isAnimating) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _float.dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    if (MediaQuery.disableAnimationsOf(context)) return;
    _bounce.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final mascotSize = 150.h;

    return SizedBox(
      height: mascotSize + 8.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _onTap,
            child: AnimatedBuilder(
              animation: Listenable.merge([_float, _bounce]),
              builder: (context, child) {
                final dy = Curves.easeInOut.transform(_float.value) * 8.h - 4.h;
                // One damped wobble: wide/short, then tall/narrow, settling.
                final t = _bounce.value;
                final wobble = math.sin(t * math.pi * 3) * (1 - t) * 0.09;
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.diagonal3Values(
                      1 + wobble,
                      1 - wobble,
                      1,
                    ),
                    child: child,
                  ),
                );
              },
              child: SizedBox.square(
                dimension: mascotSize,
                child: const _FadedMascot(),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.0).animate(animation),
                  alignment: Alignment.centerLeft,
                  child: child,
                ),
              ),
              child: _SpeechBubble(
                key: ValueKey(widget.message),
                message: widget.message,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The PNG has an opaque lavender/cream backdrop, so all four edges are
/// faded into the page background.
class _FadedMascot extends StatelessWidget {
  const _FadedMascot();

  @override
  Widget build(BuildContext context) {
    LinearGradient edgeFade(Alignment begin, Alignment end) => LinearGradient(
      begin: begin,
      end: end,
      colors: const [
        AppColors.transparent,
        AppColors.black,
        AppColors.black,
        AppColors.transparent,
      ],
      stops: const [0.0, 0.18, 0.82, 1.0],
    );

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => edgeFade(
        Alignment.centerLeft,
        Alignment.centerRight,
      ).createShader(rect),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => edgeFade(
          Alignment.topCenter,
          Alignment.bottomCenter,
        ).createShader(rect),
        child: Image.asset(AppAssets.profileMascot, fit: BoxFit.cover),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tail pointing back at the mascot.
        CustomPaint(
          size: Size(10.w, 16.h),
          painter: const _BubbleTailPainter(),
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              message,
              style: GoogleFonts.nunito(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
                height: 1.25,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
