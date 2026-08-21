// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import 'package:mint_talk/features/user_side/chat/presentation/screen/user_chat_screen.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/favorites/presentation/cubit/host_favorite_cubit.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/call_type_selection_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_state.dart';

class HostActionButtons extends StatelessWidget {
  final HostEntity host;

  const HostActionButtons({super.key, required this.host});

  void _handleCall(BuildContext context) {
    final isBusy =
        host.presence?.busy == true || host.presence?.state == 'busy';
    final isOnline =
        host.presence?.status == 'online' && !isBusy;
    if (isBusy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${host.fullName} is currently on another call.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${host.fullName} is currently offline. We will notify you when they are online.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isAudioAvailable = host.presence?.audioAvailable ?? true;
    final isVideoAvailable = host.presence?.videoAvailable ?? true;

    if (isAudioAvailable && isVideoAvailable) {
      CallTypeSelectionBottomSheet.show(context, host);
    } else if (isVideoAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            hostId: host.id,
            hostName: host.fullName,
            hostAvatar: host.avatarUrl,
            callType: CallType.video,
          ),
        ),
      );
    } else if (isAudioAvailable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            hostId: host.id,
            hostName: host.fullName,
            hostAvatar: host.avatarUrl,
            callType: CallType.audio,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${host.fullName} is currently not accepting calls.'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleBlockToggle(BuildContext context, bool isBlocked) {
    final cubit = context.read<BlockedUsersCubit>();
    if (isBlocked) {
      showDialog(
        context: context,
        builder: (_) => ConfirmationDialog(
          icon: Icons.block_rounded,
          iconColor: AppColors.primaryColor,
          accentColor: AppColors.primaryColor,
          title: 'Unblock ${host.fullName}?',
          content: 'You will be able to call and message ${host.fullName} again.',
          confirmButtonText: 'Unblock',
          cancelButtonText: 'Cancel',
          onConfirm: () {
            Navigator.pop(context);
            cubit.unblockUser(host.id);
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => ConfirmationDialog(
          icon: Icons.block_rounded,
          iconColor: AppColors.red,
          accentColor: AppColors.red,
          title: 'Block ${host.fullName}?',
          content: 'Blocking will prevent you from calling or messaging ${host.fullName}. You can unblock anytime.',
          confirmButtonText: 'Block',
          cancelButtonText: 'Cancel',
          onConfirm: () {
            Navigator.pop(context);
            cubit.blockUser(host.id);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HostFavoriteCubit>()..setInitial(host.isFavorite),
      child: BlocBuilder<BlockedUsersCubit, BlockedUsersState>(
        builder: (context, state) {
          final isBlocked = state is BlockedUsersLoaded &&
              state.users.any((u) => u.blockedId == host.id || u.id == host.id);

          return Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(13),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: AppColors.grey.withAlpha(26)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ActionButton(
                  icon: Icons.call,
                  label: AppTexts.call,
                  color: AppColors.actionBlue,
                  onTap: () => _handleCall(context),
                ),
                _ActionButton(
                  icon: Icons.message,
                  label: AppTexts.message,
                  color: AppColors.actionBlue,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.userChatScreen,
                      arguments: UserChatArgs(
                        recipientId: host.id,
                        recipientName: host.fullName,
                        recipientAvatarUrl: host.avatarUrl,
                        isOnline: host.presence?.status == 'online' &&
                            host.presence?.busy != true,
                      ),
                    );
                  },
                ),
                BlocBuilder<HostFavoriteCubit, bool>(
                  builder: (context, isFavorite) => _ActionButton(
                    icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                    iconWidget: _AnimatedFavoriteIcon(isFavorite: isFavorite),
                    label: AppTexts.favorite,
                    color: AppColors.actionBlue,
                    onTap: () => context.read<HostFavoriteCubit>().toggle(host.id),
                  ),
                ),
                _ActionButton(
                  icon: isBlocked ? Icons.person : Icons.person_off,
                  label: isBlocked ? 'Unblock' : AppTexts.block,
                  color: isBlocked ? AppColors.red : AppColors.actionBlue,
                  onTap: () => _handleBlockToggle(context, isBlocked),
                  isBlocked: isBlocked,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isBlocked;

  const _ActionButton({
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.color,
    required this.onTap,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: iconWidget ?? Icon(icon, color: AppColors.white, size: 28.sp),
                ),
              ),
              if (isBlocked)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.block, color: AppColors.red, size: 16.sp),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedFavoriteIcon extends StatelessWidget {
  final bool isFavorite;

  const _AnimatedFavoriteIcon({required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: isFavorite ? 400 : 200),
      transitionBuilder: (child, animation) {
        // Favoriting gets a bouncy pop-in; unfavoriting just fades — the
        // pop is the "you just added this" feedback, so it only belongs
        // on the way in.
        if (isFavorite) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
            child: child,
          );
        }
        return FadeTransition(opacity: animation, child: child);
      },
      child: Stack(
        key: ValueKey(isFavorite),
        alignment: Alignment.center,
        children: [
          // Icon has no native stroke, so a slightly larger white copy
          // behind the red glyph fakes a thin outline around it.
          Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: AppColors.white,
            size: 31.sp,
          ),
          Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: AppColors.favIcon,
            size: 28.sp,
          ),
        ],
      ),
    );
  }
}
