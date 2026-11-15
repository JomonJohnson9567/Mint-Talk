import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';

/// One notification row: type icon, title, message, time and an unread dot.
class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final bool showDivider;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    this.showDivider = true,
  });

  static const double _iconSize = 46;

  IconData get _typeIcon => switch (notification.type) {
    'system' => Icons.info_rounded,
    'payment' => Icons.account_balance_wallet_rounded,
    'call' => Icons.call_rounded,
    'target' => Icons.flag_rounded,
    'withdrawal' => Icons.payments_rounded,
    _ => Icons.notifications_rounded,
  };

  Color get _typeColor => switch (notification.type) {
    'system' => AppColors.primaryColor,
    'payment' => AppColors.onlineIndicator,
    'call' => AppColors.audioAccent,
    'target' => AppColors.ratingGold,
    'withdrawal' => AppColors.onlineIndicator,
    _ => AppColors.plumMuted,
  };

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.cw),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.cw),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _iconSize.cw,
                  height: _iconSize.cw,
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_typeIcon, size: 21.csp, color: _typeColor),
                ),
                SizedBox(width: 14.cw),
                Expanded(
                  child: Opacity(
                    opacity: isUnread ? 1 : 0.75,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15.5.csp,
                            fontWeight: isUnread
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: AppColors.plumDeep,
                          ),
                        ),
                        SizedBox(height: 4.cw),
                        Text(
                          notification.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.csp,
                            color: AppColors.plumMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10.cw),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 2.cw),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12.csp,
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isUnread
                            ? AppColors.primaryColor
                            : AppColors.plumMuted,
                      ),
                    ),
                    if (isUnread) ...[
                      SizedBox(height: 8.cw),
                      Container(
                        width: 9.cw,
                        height: 9.cw,
                        decoration: const BoxDecoration(
                          color: AppColors.audioAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: (_iconSize + 14).cw,
            color: AppColors.profileDivider,
          ),
      ],
    );
  }

  /// `Just now` / `5m` / `3h` for today, `09:15 PM` before that — the section
  /// label above already carries the date.
  static String _formatTime(DateTime createdAt) {
    final time = createdAt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (DateUtils.isSameDay(time, now)) return '${diff.inHours}h';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
