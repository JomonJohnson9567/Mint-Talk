import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Illustration + message shown below the filter pills when there's nothing
/// to list.
///
/// [NotificationsEmptyState.none] covers an empty inbox,
/// [NotificationsEmptyState.allCaughtUp] the Unread filter with nothing unread
/// and [NotificationsEmptyState.failure] offers a retry. Shared by the user
/// and host screens, so no variant navigates anywhere.
class NotificationsEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? mascot;
  final IconData? icon;
  final VoidCallback? onRetry;

  const NotificationsEmptyState.none({super.key})
    : title = AppTexts.noNotificationsYet,
      message = AppTexts.noNotificationsYetDesc,
      mascot = AppAssets.callLogMascot,
      icon = null,
      onRetry = null;

  const NotificationsEmptyState.allCaughtUp({super.key})
    : title = AppTexts.allCaughtUp,
      message = AppTexts.allCaughtUpDesc,
      mascot = null,
      icon = Icons.done_all_rounded,
      onRetry = null;

  const NotificationsEmptyState.failure({
    super.key,
    required this.message,
    required VoidCallback this.onRetry,
  }) : title = AppTexts.unableToLoadNotifications,
       mascot = AppAssets.callLogMascot,
       icon = null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.cw, vertical: 32.cw),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mascot != null) ...[
            Image.asset(mascot!, width: 130.cw),
            SizedBox(height: 16.cw),
          ] else if (icon != null) ...[
            Container(
              width: 88.cw,
              height: 88.cw,
              decoration: const BoxDecoration(
                color: AppColors.pricePill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40.csp, color: AppColors.primaryColor),
            ),
            SizedBox(height: 18.cw),
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
          if (onRetry != null) ...[
            SizedBox(height: 22.cw),
            _RetryPill(onTap: onRetry!),
          ],
        ],
      ),
    );
  }
}

/// Plum gradient pill (same gradient as the balance / coin cards) with a
/// round icon bubble.
class _RetryPill extends StatelessWidget {
  final VoidCallback onTap;

  const _RetryPill({required this.onTap});

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
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 19.csp,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 12.cw),
                Text(
                  AppTexts.retry,
                  style: GoogleFonts.nunito(
                    fontSize: 15.5.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
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
