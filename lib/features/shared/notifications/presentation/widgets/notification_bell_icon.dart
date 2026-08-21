import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';

/// Header bell icon with a live unread-count badge, backed by the single
/// app-wide [NotificationsCubit] instance (provided at the app root).
class NotificationBellIcon extends StatelessWidget {
  final VoidCallback onTap;

  const NotificationBellIcon({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.select<NotificationsCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSoft, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.notifications_rounded, size: 20.sp, color: AppColors.primaryColor),
            if (unreadCount > 0)
              Positioned(
                top: -2.h,
                right: -2.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                  decoration: BoxDecoration(
                    color: AppColors.favIcon,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: AppColors.white, width: 1.5.w),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
