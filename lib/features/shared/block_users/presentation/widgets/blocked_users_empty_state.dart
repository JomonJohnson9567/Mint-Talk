import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../screen/blocked_list_kind.dart';

/// Shown in place of the list when nobody is blocked
/// ([BlockedUsersEmptyState.none]) or the list failed to load
/// ([BlockedUsersEmptyState.failure], with a retry).
class BlockedUsersEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? mascot;
  final VoidCallback? onRetry;

  BlockedUsersEmptyState.none({super.key, required BlockedListKind kind})
    : title = kind.emptyTitle,
      message = kind.emptyMessage,
      mascot = null,
      onRetry = null;

  const BlockedUsersEmptyState.failure({
    super.key,
    required this.message,
    required VoidCallback this.onRetry,
  }) : title = AppTexts.unableToLoadBlocked,
       mascot = AppAssets.callLogMascot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.cw, vertical: 48.cw),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mascot != null) ...[
            Image.asset(mascot!, width: 130.cw),
            SizedBox(height: 16.cw),
          ] else ...[
            Container(
              width: 88.cw,
              height: 88.cw,
              decoration: const BoxDecoration(
                color: AppColors.pricePill,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_rounded,
                size: 40.csp,
                color: AppColors.primaryColor,
              ),
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
