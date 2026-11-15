import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/plan_tier.dart';

/// Visual theme a recharge plan card morphs into when selected, plus the
/// tier tint its unselected border, section medallion and Continue button use.
@immutable
class PlanTierTheme {
  const PlanTierTheme({
    required this.gradientColors,
    required this.ink,
    required this.mutedInk,
    required this.accent,
    required this.glow,
    required this.sheen,
    required this.pill,
    required this.checkBackground,
    required this.checkInk,
    required this.icon,
  });

  /// Top-left → bottom-right fill of a selected card.
  final List<Color> gradientColors;

  /// Coin count and price text on the selected fill.
  final Color ink;

  /// "Coins" label on the selected fill.
  final Color mutedInk;

  /// Selected border; at reduced alpha, the unselected border.
  final Color accent;

  /// Drop shadow under a selected card.
  final Color glow;

  /// Highlight band that sweeps across a card when it is selected.
  final Color sheen;

  /// Price pill background on the selected fill.
  final Color pill;

  final Color checkBackground;
  final Color checkInk;

  /// Section header medallion icon.
  final IconData icon;

  /// Border color of an unselected card.
  Color get softAccent => accent.withValues(alpha: 0.4);

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
        stops: const [0, 0.55, 1],
      );

  static PlanTierTheme of(PlanTier tier) => switch (tier) {
        PlanTier.silver => silver,
        PlanTier.gold => gold,
        PlanTier.platinum => platinum,
        PlanTier.other => other,
      };

  static final silver = PlanTierTheme(
    gradientColors: const [
      AppColors.silverStart,
      AppColors.silverMid,
      AppColors.silverEnd,
    ],
    ink: AppColors.silverInk,
    mutedInk: AppColors.silverMutedInk,
    accent: AppColors.silverAccent,
    glow: AppColors.silverAccent.withValues(alpha: 0.45),
    sheen: AppColors.white.withValues(alpha: 0.85),
    pill: AppColors.silverInk.withValues(alpha: 0.1),
    checkBackground: AppColors.silverInk,
    checkInk: AppColors.white,
    icon: Icons.military_tech_rounded,
  );

  static final gold = PlanTierTheme(
    gradientColors: const [
      AppColors.goldStart,
      AppColors.goldMid,
      AppColors.goldEnd,
    ],
    ink: AppColors.goldInk,
    mutedInk: AppColors.goldMutedInk,
    accent: AppColors.goldAccent,
    glow: AppColors.goldEnd.withValues(alpha: 0.5),
    sheen: AppColors.goldStart.withValues(alpha: 0.9),
    pill: AppColors.goldInk.withValues(alpha: 0.12),
    checkBackground: AppColors.goldInk,
    checkInk: AppColors.goldCheckInk,
    icon: Icons.military_tech_rounded,
  );

  static final platinum = PlanTierTheme(
    gradientColors: const [
      AppColors.platinumStart,
      AppColors.platinumMid,
      AppColors.platinumEnd,
    ],
    ink: AppColors.platinumInk,
    mutedInk: AppColors.platinumMutedInk,
    accent: AppColors.platinumAccent,
    glow: AppColors.platinumMid.withValues(alpha: 0.55),
    sheen: AppColors.platinumSheen.withValues(alpha: 0.55),
    pill: AppColors.platinumInk.withValues(alpha: 0.14),
    checkBackground: AppColors.platinumCheckBg,
    checkInk: AppColors.platinumEnd,
    icon: Icons.workspace_premium_rounded,
  );

  /// Plans without a recognised tier (e.g. the static fallback catalogue)
  /// keep the app's plum card look.
  static final other = PlanTierTheme(
    gradientColors: const [
      AppColors.cardWhite,
      AppColors.popularCardBg,
      AppColors.pricePill,
    ],
    ink: AppColors.plumDeep,
    mutedInk: AppColors.plumMuted,
    accent: AppColors.primaryColor,
    glow: AppColors.primaryColor.withValues(alpha: 0.25),
    sheen: AppColors.white.withValues(alpha: 0.8),
    pill: AppColors.primaryColor.withValues(alpha: 0.1),
    checkBackground: AppColors.primaryColor,
    checkInk: AppColors.white,
    icon: Icons.local_offer_rounded,
  );
}
