import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import 'package:mint_talk/features/user_side/chat/presentation/screen/user_chat_screen.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/favorites/presentation/cubit/host_favorite_cubit.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/outgoing_call_launcher.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_state.dart';

class HostActionButtons extends StatelessWidget {
  final HostEntity host;

  const HostActionButtons({super.key, required this.host});

  void _handleCall(BuildContext context) {
    final isBusy = host.presence?.isOnCall ?? false;
    final isOnline = host.presence?.isAvailableForCalls ?? false;
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
          content: Text(
            '${host.fullName} is currently offline. We will notify you when they are online.',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    pickCallTypeThen(
      context,
      host,
      (type) => launchOutgoingCall(context, host: host, callType: type),
    );
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
          content:
              'You will be able to call and message ${host.fullName} again.',
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
          content:
              'Blocking will prevent you from calling or messaging ${host.fullName}. You can unblock anytime.',
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
          final isBlocked =
              state is BlockedUsersLoaded &&
              state.users.any((u) => u.blockedId == host.id || u.id == host.id);

          return Container(
            padding: EdgeInsets.symmetric(vertical: 16.cw, horizontal: 8.cw),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(18.cw),
              border: Border.all(color: AppColors.profileDivider),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.call_rounded,
                    label: AppTexts.call,
                    isPrimary: true,
                    onTap: () => _handleCall(context),
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: AppTexts.message,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.userChatScreen,
                        arguments: UserChatArgs(
                          recipientId: host.id,
                          recipientName: host.fullName,
                          recipientAvatarUrl: host.avatarUrl,
                          isOnline:
                              host.presence?.status == 'online' &&
                              host.presence?.isOnCall != true,
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<HostFavoriteCubit, bool>(
                    builder: (context, isFavorite) => _ActionButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconWidget: _AnimatedFavoriteIcon(isFavorite: isFavorite),
                      label: AppTexts.favorite,
                      onTap: () =>
                          context.read<HostFavoriteCubit>().toggle(host.id),
                    ),
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.block_rounded,
                    label: isBlocked ? 'Unblock' : AppTexts.block,
                    onTap: () => _handleBlockToggle(context, isBlocked),
                    isBlocked: isBlocked,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Round chip + label. [isPrimary] fills the chip with the brand plum;
/// [isBlocked] switches it to the magenta "Unblock" treatment.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isBlocked;

  const _ActionButton({
    required this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = 56.cw;
    final Color chipColor;
    final Color iconColor;
    if (isPrimary) {
      chipColor = AppColors.primaryColor;
      iconColor = AppColors.white;
    } else if (isBlocked) {
      chipColor = AppColors.pillUnselected;
      iconColor = AppColors.linkMagenta;
    } else {
      chipColor = AppColors.popularCardBg;
      iconColor = AppColors.primaryColor;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isPrimary
                      ? [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: chipColor,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onTap,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Center(
                        child:
                            iconWidget ??
                            Icon(icon, color: iconColor, size: 26.csp),
                      ),
                    ),
                  ),
                ),
              ),
              if (isBlocked)
                Positioned(
                  right: -2.cw,
                  top: -2.cw,
                  child: Container(
                    padding: EdgeInsets.all(2.cw),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_rounded,
                      color: AppColors.linkMagenta,
                      size: 14.csp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.cw),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.5.csp,
            fontWeight: FontWeight.w700,
            color: isBlocked ? AppColors.linkMagenta : AppColors.plumDeep,
          ),
        ),
      ],
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
      child: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(isFavorite),
        color: isFavorite ? AppColors.favIcon : AppColors.primaryColor,
        size: 26.csp,
      ),
    );
  }
}
