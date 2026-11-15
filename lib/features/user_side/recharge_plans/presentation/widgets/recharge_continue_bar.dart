import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/screen/plan_detail_screen.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/theme/plan_tier_theme.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

/// Sticky bar that slides up once a plan is selected. Its burgundy button
/// opens Plan Detail, where checkout starts; each new selection sends one
/// wave of the selected tier's colors across it before it settles back.
class RechargeContinueBar extends StatelessWidget {
  const RechargeContinueBar({
    super.key,
    required this.plan,
    required this.visible,
  });

  /// The selected plan — or, while sliding out, the last one selected, so
  /// the bar doesn't go blank mid-animation. Null before any selection.
  final RechargePlanEntity? plan;
  final bool visible;

  static const slideDuration = Duration(milliseconds: 280);

  /// Room the scroll view leaves at its bottom so the bar never covers the
  /// last content.
  static double get reservedHeight => 116.cw;

  void _onContinue(BuildContext context, RechargePlanEntity plan) {
    Navigator.pushNamed(
      context,
      AppRoutes.planDetail,
      arguments: PlanDetailArgs(planId: plan.id, plan: plan),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = this.plan;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : slideDuration;
    final isShown = visible && plan != null;

    return IgnorePointer(
      ignoring: !isShown,
      child: AnimatedSlide(
        offset: isShown ? Offset.zero : const Offset(0, 1.2),
        duration: duration,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: isShown ? 1 : 0,
          duration: duration,
          child: plan == null
              ? const SizedBox.shrink()
              : _BarBody(
                  plan: plan,
                  visible: isShown,
                  onContinue: () => _onContinue(context, plan),
                ),
        ),
      ),
    );
  }
}

class _BarBody extends StatelessWidget {
  const _BarBody({
    required this.plan,
    required this.visible,
    required this.onContinue,
  });

  final RechargePlanEntity plan;
  final bool visible;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final name = plan.name?.trim();
    final bonus = plan.bonusPoints ?? 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.rechargeBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 14.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    [
                      if (name != null && name.isNotEmpty) name,
                      '${IndianNumberFormat.format(plan.coinAmount)} ${AppTexts.coinsSuffix.toLowerCase()}',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                    ),
                  ),
                ),
                if (bonus > 0)
                  Text(
                    '+${IndianNumberFormat.format(bonus)} ${AppTexts.bonus}',
                    style: TextStyle(
                      fontSize: 12.5.csp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.plumMuted,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.cw),
            _WaveButton(
              plan: plan,
              visible: visible,
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

/// Burgundy Continue button. When a plan is selected (or the selection moves
/// to another plan) one wave of that plan's tier gradient sweeps across it
/// left → right, then the button is plain burgundy again.
///
/// Stateful only for the one-shot wave [AnimationController].
class _WaveButton extends StatefulWidget {
  const _WaveButton({
    required this.plan,
    required this.visible,
    required this.onPressed,
  });

  final RechargePlanEntity plan;
  final bool visible;
  final VoidCallback onPressed;

  static const waveDuration = Duration(milliseconds: 1100);

  @override
  State<_WaveButton> createState() => _WaveButtonState();
}

class _WaveButtonState extends State<_WaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: _WaveButton.waveDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First build happens on the first selection.
    if (widget.visible && _wave.status == AnimationStatus.dismissed) {
      _playWave();
    }
  }

  @override
  void didUpdateWidget(covariant _WaveButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    final reshown = widget.visible && !oldWidget.visible;
    final reselected =
        widget.visible && widget.plan.id != oldWidget.plan.id;
    if (reshown || reselected) _playWave();
  }

  void _playWave() {
    if (MediaQuery.disableAnimationsOf(context)) return;
    _wave.forward(from: 0);
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PlanTierTheme.of(widget.plan.tier);
    final radius = BorderRadius.circular(14.cw);

    return AnimatedBuilder(
      animation: _wave,
      builder: (context, child) {
        final progress = Curves.easeInOutCubic.transform(_wave.value);
        // 0 at rest, peaking mid-sweep: shifts the label from white toward
        // the tier ink so it stays readable on light silver/gold.
        final intensity = _wave.isAnimating
            ? math.sin(math.pi * _wave.value).clamp(0.0, 1.0)
            : 0.0;

        return Container(
          height: 52.cw,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Color.lerp(
                  AppColors.primaryColor.withValues(alpha: 0.3),
                  theme.glow,
                  intensity,
                )!,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onPressed,
                splashColor: AppColors.white.withValues(alpha: 0.16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_wave.isAnimating)
                      IgnorePointer(
                        child: ClipPath(
                          clipper: _WaveBandClipper(progress: progress),
                          child: DecoratedBox(
                            decoration: BoxDecoration(gradient: theme.gradient),
                          ),
                        ),
                      ),
                    Center(
                      child: Text(
                        '${AppTexts.continueText} · ${AppTexts.rupeeSymbol}${IndianNumberFormat.format(widget.plan.numericPrice)}',
                        style: GoogleFonts.nunito(
                          fontSize: 16.csp,
                          fontWeight: FontWeight.w900,
                          color: Color.lerp(
                            AppColors.white,
                            theme.ink,
                            intensity,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A vertical band with sine-wave edges that travels from fully off the
/// left edge ([progress] 0) to fully off the right edge ([progress] 1).
class _WaveBandClipper extends CustomClipper<Path> {
  const _WaveBandClipper({required this.progress});

  final double progress;

  @override
  Path getClip(Size size) {
    final bandWidth = size.width * 0.75;
    final amplitude = size.height * 0.22;
    final travel = size.width + bandWidth + amplitude * 2;
    final left = -bandWidth - amplitude + travel * progress;
    final right = left + bandWidth;
    // The crest drifts as the band moves so the edge reads as a moving wave.
    final phase = progress * math.pi * 3;

    double edge(double base, double y) =>
        base + amplitude * math.sin(phase + y / size.height * 2 * math.pi);

    const steps = 12;
    final path = Path()..moveTo(edge(left, 0), 0);
    path.lineTo(edge(right, 0), 0);
    for (var i = 1; i <= steps; i++) {
      final y = size.height * i / steps;
      path.lineTo(edge(right, y), y);
    }
    path.lineTo(edge(left, size.height), size.height);
    for (var i = steps - 1; i >= 0; i--) {
      final y = size.height * i / steps;
      path.lineTo(edge(left, y), y);
    }
    return path..close();
  }

  @override
  bool shouldReclip(_WaveBandClipper oldClipper) =>
      oldClipper.progress != progress;
}
