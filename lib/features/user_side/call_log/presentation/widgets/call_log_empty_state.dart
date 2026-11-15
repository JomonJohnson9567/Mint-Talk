import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/cubit/bottom_nav_cubit.dart';

/// Mascot + message shown below the header when there's nothing to list.
///
/// [CallLogEmptyState.noCalls] points a first-time user to Home,
/// [CallLogEmptyState.noMatches] covers search/filters that hide every row and
/// [CallLogEmptyState.failure] offers a retry.
class CallLogEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? mascot;
  final double mascotWidth;
  final String? actionText;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const CallLogEmptyState._({
    required this.title,
    required this.message,
    required this.mascot,
    required this.mascotWidth,
    required this.actionText,
    required this.actionIcon,
    required this.onAction,
  });

  /// Home is index 1 in MainNavigationScreen's tabs.
  static const int _homeTabIndex = 1;

  factory CallLogEmptyState.noCalls(BuildContext context) {
    return CallLogEmptyState._(
      title: AppTexts.noCallsYet,
      message: AppTexts.noCallsYetDesc,
      // Transparent cut-out, so it sits straight on the cream page.
      mascot: AppAssets.noCallsMascot,
      mascotWidth: 210,
      actionText: AppTexts.findSomeoneToTalk,
      actionIcon: Icons.call_rounded,
      onAction: () => context.read<BottomNavCubit>().changeTab(_homeTabIndex),
    );
  }

  const CallLogEmptyState.noMatches({super.key})
    : title = AppTexts.noMatchingCalls,
      message = AppTexts.noMatchingCallsDesc,
      mascot = null,
      mascotWidth = 0,
      actionText = null,
      actionIcon = null,
      onAction = null;

  const CallLogEmptyState.failure({
    super.key,
    required this.message,
    required VoidCallback this.onAction,
  }) : title = AppTexts.unableToLoadCalls,
       mascot = AppAssets.callLogMascot,
       mascotWidth = 130,
       actionText = AppTexts.retry,
       actionIcon = Icons.refresh_rounded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.cw, vertical: 24.cw),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mascot != null) ...[
            Image.asset(mascot!, width: mascotWidth.cw),
            SizedBox(height: 16.cw),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 20.csp,
              fontWeight: FontWeight.w800,
              color: AppColors.plumDeep,
            ),
          ),
          SizedBox(height: 8.cw),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.csp,
              color: AppColors.plumMuted,
              height: 1.45,
            ),
          ),
          if (actionText != null && actionIcon != null && onAction != null) ...[
            SizedBox(height: 22.cw),
            _ActionPill(
              label: actionText!,
              icon: actionIcon!,
              onTap: onAction!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Plum gradient pill (same gradient as the balance / coin cards) with a
/// round icon bubble echoing the rows' call-back buttons. Sizes to its label
/// so longer copy never wraps.
class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30.cw);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          colors: [AppColors.balanceCardStart, AppColors.primaryColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.fromLTRB(6.cw, 6.cw, 22.cw, 6.cw),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38.cw,
                  height: 38.cw,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 19.csp, color: AppColors.white),
                ),
                SizedBox(width: 12.cw),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 15.5.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
