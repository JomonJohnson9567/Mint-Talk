import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'notification_tile.dart';
import '../cubit/notifications_cubit.dart';
import '../cubit/notifications_state.dart';

class NotificationsListBody extends StatelessWidget {
  const NotificationsListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == NotificationsStatus.failure && state.notifications.isEmpty) {
          return _MessageView(
            icon: Icons.error_outline_rounded,
            message: state.errorMessage ?? 'Failed to load notifications',
            onRetry: () => context.read<NotificationsCubit>().loadNotifications(),
          );
        }

        if (state.notifications.isEmpty) {
          return const _MessageView(
            icon: Icons.notifications_none_rounded,
            message: 'No notifications yet.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<NotificationsCubit>().loadNotifications(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                context.read<NotificationsCubit>().loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                if (index >= state.notifications.length) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = state.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => context.read<NotificationsCubit>().markAsRead(notification.id),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const _MessageView({required this.icon, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.sp, color: AppColors.subtitleText),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.subtitleText),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.h),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
