import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../cubit/notifications_cubit.dart';

class MarkAllReadAction extends StatelessWidget {
  const MarkAllReadAction({super.key});

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationsCubit, bool>(
      (cubit) => cubit.state.unreadCount > 0,
    );

    if (!hasUnread) return const SizedBox.shrink();

    return TextButton(
      onPressed: () => context.read<NotificationsCubit>().markAllAsRead(),
      child: Text(
        'Mark all read',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
