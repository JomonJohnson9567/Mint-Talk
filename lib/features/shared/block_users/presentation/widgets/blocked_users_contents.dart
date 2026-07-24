import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import '../cubit/blocked_users_cubit.dart';
import '../cubit/blocked_users_state.dart';
import '../../domain/entities/blocked_user_entity.dart';

class BlockedUsersContents extends StatelessWidget {
  const BlockedUsersContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BlockedUsersCubit, BlockedUsersState>(
      listener: (context, state) {
        if (state is BlockedUsersLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: AppColors.green,
            ),
          );
        } else if (state is BlockedUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BlockedUsersLoading || state is BlockedUsersInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (state is BlockedUsersLoaded) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () => context.read<BlockedUsersCubit>().loadBlockedUsers(),
            child: state.users.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: const _EmptyBlockedUsers(),
                    ),
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    itemCount: state.users.length,
                    separatorBuilder: (context, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _BlockedUserItem(user: user);
                    },
                  ),
          );
        }

        return const Center(child: Text('Failed to load blocked users'));
      },
    );
  }
}

class _BlockedUserItem extends StatelessWidget {
  final BlockedUserEntity user;

  const _BlockedUserItem({required this.user});

  void _confirmUnblock(BuildContext context) {
    final cubit = context.read<BlockedUsersCubit>();
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialog(
        icon: Icons.block_rounded,
        iconColor: AppColors.primaryColor,
        accentColor: AppColors.primaryColor,
        title: 'Unblock ${user.fullName.isNotEmpty ? user.fullName : 'User'}?',
        content:
            '${user.fullName.isNotEmpty ? user.fullName : 'This user'} will be able to contact and call you again.',
        confirmButtonText: 'Unblock',
        cancelButtonText: 'Cancel',
        onConfirm: () {
          Navigator.pop(context);
          cubit.unblockUser(user.blockedId.isNotEmpty ? user.blockedId : user.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = user.fullName.isNotEmpty ? user.fullName : 'Blocked User';
    final avatar = user.avatarUrl.isNotEmpty ? user.avatarUrl : AppAssets.femaleIcon;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
            backgroundImage: NetworkImage(avatar),
            onBackgroundImageError: (exception, stackTrace) {},
            child: Icon(Icons.person, color: AppColors.primaryColor, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                if (user.role.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subtitleText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _confirmUnblock(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
            child: Text(
              'Unblock',
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
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
            Icons.block_outlined,
            size: 64.sp,
            color: AppColors.subtitleText.withAlpha(100),
          ),
          SizedBox(height: 16.h),
          Text(
            'No Blocked Users',
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Users you block will appear here.',
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              color: AppColors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}
