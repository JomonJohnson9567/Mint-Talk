import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Confirmation bottom sheet with the hesitant MintTalk mascot — shared by the
/// exit, logout and delete-account prompts. Resolves to `true` only when the
/// confirm button is tapped; cancel, swipe-down, scrim tap and back all
/// resolve to `false`.
class MascotConfirmSheet extends StatefulWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;

  /// Optional pill shown under [message], tinted with [confirmColor] — used
  /// to flag destructive actions.
  final String? warning;

  const MascotConfirmSheet({
    super.key,
    required this.title,
    required this.message,
    required this.cancelText,
    required this.confirmText,
    this.confirmColor = AppColors.primaryColor,
    this.warning,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String cancelText,
    required String confirmText,
    Color confirmColor = AppColors.primaryColor,
    String? warning,
  }) async {
    HapticFeedback.selectionClick();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MascotConfirmSheet(
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        warning: warning,
      ),
    );
    return confirmed ?? false;
  }

  @override
  State<MascotConfirmSheet> createState() => _MascotConfirmSheetState();
}

class _MascotConfirmSheetState extends State<MascotConfirmSheet>
    with SingleTickerProviderStateMixin {
  // Drives the mascot's hesitant idle bob.
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _bob.stop();
    } else if (!_bob.isAnimating) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warning = widget.warning;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20.cw, 10.cw, 20.cw, 16.cw),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.cw,
              height: 4.cw,
              decoration: BoxDecoration(
                color: AppColors.lavenderBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 12.cw),
            _Entrance(
              duration: const Duration(milliseconds: 280),
              child: _MascotHero(bob: _bob),
            ),
            SizedBox(height: 14.cw),
            _Entrance(
              duration: const Duration(milliseconds: 360),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                    ),
                  ),
                  SizedBox(height: 8.cw),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.csp,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: AppColors.plumMuted,
                    ),
                  ),
                  if (warning != null) ...[
                    SizedBox(height: 12.cw),
                    _WarningPill(text: warning, color: widget.confirmColor),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24.cw),
            _Entrance(
              duration: const Duration(milliseconds: 440),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52.cw,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.videoCardBg,
                          foregroundColor: AppColors.primaryColor,
                          side: const BorderSide(
                            color: AppColors.primaryColor,
                            width: 1.2,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          widget.cancelText,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 16.csp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.cw),
                  Expanded(
                    child: PrimaryButton(
                      text: widget.confirmText,
                      height: 52.cw,
                      backgroundColor: widget.confirmColor,
                      textStyle: TextStyle(
                        fontSize: 16.csp,
                        fontWeight: FontWeight.w700,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarningPill extends StatelessWidget {
  final String text;
  final Color color;

  const _WarningPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 6.cw),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 15.csp, color: color),
          SizedBox(width: 6.cw),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.csp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mascot on a soft lavender halo with a ground shadow that tightens as the
/// bird floats up.
class _MascotHero extends StatelessWidget {
  final Animation<double> bob;

  const _MascotHero({required this.bob});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172.cw,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: bob,
        builder: (context, mascot) {
          final t = Curves.easeInOut.transform(bob.value);
          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 18.cw,
                child: Container(
                  width: 236.cw,
                  height: 128.cw,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.videoCardBg,
                        AppColors.videoCardBg.withValues(alpha: 0.55),
                      ],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(118.cw, 64.cw),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2.cw,
                child: Transform.scale(
                  scaleX: 1 - 0.18 * t,
                  child: Container(
                    width: 104.cw,
                    height: 12.cw,
                    decoration: BoxDecoration(
                      color: AppColors.plumDeep.withValues(
                        alpha: 0.14 - 0.05 * t,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.elliptical(52.cw, 6.cw),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 6.cw,
                child: Transform.translate(
                  offset: Offset(0, -6.cw * t),
                  child: Transform.rotate(
                    angle: (t - 0.5) * 0.07,
                    child: mascot,
                  ),
                ),
              ),
            ],
          );
        },
        child: Image.asset(
          AppAssets.exitMascot,
          height: 156.cw,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Fades and slides [child] up over [duration]; staggered per section the
/// same way as the call-type sheet's option cards.
class _Entrance extends StatelessWidget {
  final Duration duration;
  final Widget child;

  const _Entrance({required this.duration, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16.cw),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
