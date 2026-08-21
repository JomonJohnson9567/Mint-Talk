import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.notification, required this.onTap});

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
        'call' => AppColors.actionBlue,
        'target' => AppColors.orange,
        'withdrawal' => AppColors.onlineIndicator,
        _ => AppColors.primaryColor,
      };

  String get _relativeTime {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final date = notification.createdAt;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread ? AppColors.softBlue : AppColors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isUnread ? _typeColor.withValues(alpha: 0.25) : AppColors.borderSoft,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_typeIcon, size: 18.sp, color: _typeColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            margin: EdgeInsets.only(left: 6.w, top: 2.h),
                            decoration: BoxDecoration(
                              color: _typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.subtitleText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _relativeTime,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitleText.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
