import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_state.dart';
import 'package:mint_talk/features/host_side/block_users/presentation/widgets/blocked_user_tile.dart';

class BlockedUsersContents extends StatelessWidget {
  const BlockedUsersContents({super.key});

  void _showUnblockDialog(
    BuildContext context,
    String name,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        icon: Icons.lock_open_rounded,
        iconColor: AppColors.primaryColor,
        accentColor: AppColors.primaryColor,
        title: 'Unblock $name?',
        content: '$name will be able to contact you again after unblocking.',
        confirmButtonText: 'Unblock',
        cancelButtonText: 'Cancel',
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<BlockedUsersCubit>().unblockUser(userId);
        },
      ),
    );
  }

  void _showReportDialog(
    BuildContext context,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        icon: Icons.flag_rounded,
        iconColor: AppColors.favIcon,
        accentColor: AppColors.favIcon,
        title: 'Report $name?',
        content: 'We’ll review this blocked user if you continue with the report.',
        confirmButtonText: 'Report',
        cancelButtonText: 'Cancel',
        onConfirm: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name has been reported.')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlockedUsersCubit, BlockedUsersState>(
      listener: (context, state) {
        if (state is BlockedUsersLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionMessage!)),
          );
        } else if (state is BlockedUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is BlockedUsersLoaded) {
          if (state.users.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => context.read<BlockedUsersCubit>().loadBlockedUsers(),
              child: ListView(
                children: [
                  SizedBox(height: 200.h),
                  const _EmptyBlockedUsers(),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<BlockedUsersCubit>().loadBlockedUsers(),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final displayName = user.fullName.isNotEmpty ? user.fullName : 'User ${user.blockedId.substring(0, user.blockedId.length > 5 ? 5 : user.blockedId.length)}';
                return BlockedUserTile(
                  name: displayName,
                  imageUrl: user.avatarUrl,
                  blockedReason: user.role.isNotEmpty ? 'Role: ${user.role}' : 'Blocked user',
                  onUnblockTap: () => _showUnblockDialog(context, displayName, user.blockedId.isNotEmpty ? user.blockedId : user.id),
                  onReportTap: () => _showReportDialog(context, displayName),
                );
              },
            ),
          );
        }

        if (state is BlockedUsersError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: AppColors.red, fontSize: 14.sp),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _EmptyBlockedUsers extends StatelessWidget {
  const _EmptyBlockedUsers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block_rounded,
            size: 56.sp,
            color: AppColors.subtitleText.withAlpha(100),
          ),
          SizedBox(height: 16.h),
          Text(
            'No blocked users yet',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.subtitleText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
