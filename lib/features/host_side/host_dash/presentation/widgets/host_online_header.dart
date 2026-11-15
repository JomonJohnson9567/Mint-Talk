import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'host_welcome_card.dart';

/// Header shown while the host is online (waiting for / receiving a call):
/// wordmark with a "Host" tag, notification bell and avatar.
class HostOnlineHeader extends StatelessWidget {
  const HostOnlineHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.cw, 8.cw, 14.cw, 6.cw),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.mintTalkWordmark,
                  height: 26.cw,
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.cw),
                  child: Text(
                    AppTexts.hostRole,
                    style: TextStyle(
                      fontSize: 12.csp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.hostSubtitle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _NotificationBell(),
          SizedBox(width: 12.cw),
          const _OnlineAvatar(),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.select<NotificationsCubit, bool>(
      (cubit) => cubit.state.unreadCount > 0,
    );

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.hostNotificationsScreen),
      child: SizedBox(
        width: 36.cw,
        height: 36.cw,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 24.csp,
              color: AppColors.hostSubtitle,
            ),
            if (hasUnread)
              Positioned(
                top: 7.cw,
                right: 8.cw,
                child: Container(
                  width: 8.cw,
                  height: 8.cw,
                  decoration: BoxDecoration(
                    color: AppColors.audioAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5.cw),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnlineAvatar extends StatelessWidget {
  const _OnlineAvatar();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      HostProfileCubit,
      HostProfileState,
      ({String imagePath, String initials})
    >(
      selector: (state) =>
          (imagePath: state.imagePath ?? '', initials: state.initials),
      builder: (context, avatar) {
        return GestureDetector(
          onTap: () => openHostProfile(context),
          child: SizedBox(
            width: 50.cw,
            height: 50.cw,
            child: Stack(
              children: [
                Container(
                  width: 48.cw,
                  height: 48.cw,
                  padding: EdgeInsets.all(2.cw),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.hostAvatarBg,
                  ),
                  child: ClipOval(
                    child: HostProfileAvatar(
                      imagePath: avatar.imagePath,
                      initials: avatar.initials,
                      size: 44,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18.cw,
                    height: 18.cw,
                    decoration: BoxDecoration(
                      color: AppColors.onlineIndicator,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2.cw),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 11.csp,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
