import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/theme/plan_tier_theme.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

/// A selectable plan tile. Selecting it morphs the white card into its
/// tier's theme (gradient fill, tinted text, glow, slight scale-up), sweeps a
/// sheen across it once and pops in a check badge.
///
/// Stateful only for the one-shot sheen [AnimationController]; selection
/// itself is owned by the parent.
class RechargePlanCard extends StatefulWidget {
  const RechargePlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.showName = false,
  });

  final RechargePlanEntity plan;
  final bool isSelected;
  final VoidCallback onTap;

  /// Tier sections already name the pack in their header, so only untiered
  /// plans repeat their name on the card.
  final bool showName;

  static const morphDuration = Duration(milliseconds: 380);
  static const sheenDuration = Duration(milliseconds: 900);
  static const checkDuration = Duration(milliseconds: 450);
  static const selectedScale = 1.05;

  @override
  State<RechargePlanCard> createState() => _RechargePlanCardState();
}

class _RechargePlanCardState extends State<RechargePlanCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sheen = AnimationController(
    vsync: this,
    duration: RechargePlanCard.sheenDuration,
  );

  @override
  void didUpdateWidget(covariant RechargePlanCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected &&
        !oldWidget.isSelected &&
        !MediaQuery.disableAnimationsOf(context)) {
      _sheen.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _sheen.dispose();
    super.dispose();
  }

  String _semanticLabel(RechargePlanEntity plan) {
    final name = plan.name?.trim();
    final bonus = plan.bonusPoints ?? 0;
    return [
      if (name != null && name.isNotEmpty) name,
      '${IndianNumberFormat.format(plan.coinAmount)} ${AppTexts.coinsSuffix}',
      if (bonus > 0) '+${IndianNumberFormat.format(bonus)} ${AppTexts.bonus}',
      '${AppTexts.rupeeSymbol}${IndianNumberFormat.format(plan.numericPrice)}',
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final theme = PlanTierTheme.of(plan.tier);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(16.cw);

    return Semantics(
      button: true,
      selected: widget.isSelected,
      excludeSemantics: true,
      onTap: widget.onTap,
      label: _semanticLabel(plan),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.isSelected ? 1 : 0),
        duration: reduceMotion ? Duration.zero : RechargePlanCard.morphDuration,
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final ink = Color.lerp(AppColors.plumDeep, theme.ink, t)!;

          return Transform.scale(
            scale: 1 + (RechargePlanCard.selectedScale - 1) * t,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      AppColors.plumDeep.withValues(alpha: 0.06),
                      theme.glow,
                      t,
                    )!,
                    blurRadius: 14 + 12 * t,
                    offset: Offset(0, 6 + 6 * t),
                  ),
                ],
              ),
              child: Material(
                color: AppColors.cardWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: BorderSide(
                    width: 1.5,
                    color: Color.lerp(theme.softAccent, theme.accent, t)!,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onTap,
                  splashColor: theme.accent.withValues(alpha: 0.18),
                  highlightColor: theme.accent.withValues(alpha: 0.08),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The tier fill fades in over the white surface.
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: theme.gradient.begin,
                              end: theme.gradient.end,
                              stops: theme.gradient.stops,
                              colors: [
                                for (final color in theme.gradientColors)
                                  color.withValues(alpha: color.a * t),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _Sheen(animation: _sheen, color: theme.sheen),
                      _CardContents(
                        plan: plan,
                        showName: widget.showName,
                        ink: ink,
                        mutedInk:
                            Color.lerp(AppColors.plumHint, theme.mutedInk, t)!,
                        bonusInk:
                            Color.lerp(AppColors.primaryColor, theme.ink, t)!,
                        pillColor:
                            Color.lerp(AppColors.pricePill, theme.pill, t)!,
                      ),
                      Positioned(
                        top: 7.cw,
                        right: 7.cw,
                        child: AnimatedScale(
                          scale: widget.isSelected ? 1 : 0,
                          duration: reduceMotion
                              ? Duration.zero
                              : RechargePlanCard.checkDuration,
                          curve: widget.isSelected
                              ? Curves.easeOutBack
                              : Curves.easeIn,
                          child: Container(
                            width: 20.cw,
                            height: 20.cw,
                            decoration: BoxDecoration(
                              color: theme.checkBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 13.cw,
                              color: theme.checkInk,
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
      ),
    );
  }
}

/// Diagonal highlight band that sweeps left → right once per selection.
/// It rests off-card before and after the sweep, so nothing shows at rest.
class _Sheen extends StatelessWidget {
  const _Sheen({required this.animation, required this.color});

  final Animation<double> animation;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final progress = Curves.easeOutCubic.transform(animation.value);
          return FractionalTranslation(
            translation: Offset(-1.3 + 2.6 * progress, 0),
            child: child,
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-1, -0.4),
              end: const Alignment(1, 0.4),
              colors: [
                color.withValues(alpha: 0),
                color,
                color.withValues(alpha: 0),
              ],
              stops: const [0.28, 0.5, 0.72],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardContents extends StatelessWidget {
  const _CardContents({
    required this.plan,
    required this.showName,
    required this.ink,
    required this.mutedInk,
    required this.bonusInk,
    required this.pillColor,
  });

  final RechargePlanEntity plan;
  final bool showName;
  final Color ink;
  final Color mutedInk;
  final Color bonusInk;
  final Color pillColor;

  @override
  Widget build(BuildContext context) {
    final name = plan.name?.trim();

    return Padding(
      padding: EdgeInsets.fromLTRB(8.cw, 12.cw, 8.cw, 10.cw),
      child: Column(
        children: [
          // The tile has a fixed height (see RechargePlanGrid), so the coin
          // is the one flexible piece: it shrinks when the text runs taller
          // (real font metrics, large accessibility text, name + bonus
          // lines) instead of the card overflowing.
          Expanded(
            child: Column(
              children: [
                if (showName && name != null && name.isNotEmpty) ...[
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.csp,
                        fontWeight: FontWeight.w700,
                        color: ink,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.cw),
                ],
                Flexible(
                  child: Image.asset(
                    AppAssets.rechargeCoin,
                    width: 42.cw,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 6.cw),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    IndianNumberFormat.format(plan.coinAmount),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 17.csp,
                      fontWeight: FontWeight.w800,
                      color: ink,
                    ),
                  ),
                ),
                Text(
                  AppTexts.coinsSuffix,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.csp,
                    fontWeight: FontWeight.w600,
                    color: mutedInk,
                  ),
                ),
                if ((plan.bonusPoints ?? 0) > 0) ...[
                  SizedBox(height: 3.cw),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '+${IndianNumberFormat.format(plan.bonusPoints!)} ${AppTexts.bonus}',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10.5.csp,
                        fontWeight: FontWeight.w800,
                        color: bonusInk,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 6.cw),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 5.cw),
            decoration: BoxDecoration(
              color: pillColor,
              borderRadius: BorderRadius.circular(10.cw),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${AppTexts.rupeeSymbol} ${IndianNumberFormat.format(plan.numericPrice)}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14.csp,
                  fontWeight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
