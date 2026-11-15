import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/cubit/bottom_nav_cubit.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/become_host_banner.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_coin_card.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_header_card.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_menu_card.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_page_header.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/contact_us_bottom_sheet.dart';

/// Index of the Calls (call log) tab in the main navigation shell.
const int _callsTabIndex = 0;

class ProfileContents extends StatelessWidget {
  const ProfileContents({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      // Bottom inset clears the floating nav bar (extendBody: true).
      padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 110.cw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfilePageHeader(),
          SizedBox(height: 14.cw),
          const ProfileHeaderCard(),
          SizedBox(height: 12.cw),
          const ProfileCoinCard(),
          SizedBox(height: 12.cw),
          const BecomeHostBanner(),
          SizedBox(height: 12.cw),
          ProfileMenuCard(items: _menuItems(context)),
        ],
      ),
    );
  }

  List<ProfileMenuItem> _menuItems(BuildContext context) {
    return [
      ProfileMenuItem(
        icon: Icons.access_time_rounded,
        label: AppTexts.callHistory,
        // Null when this screen is opened outside the main navigation shell.
        onTap: () => context.read<BottomNavCubit?>()?.changeTab(_callsTabIndex),
      ),
      ProfileMenuItem(
        icon: Icons.chat_bubble_outline_rounded,
        label: AppTexts.conversations,
        onTap: () => Navigator.pushNamed(context, AppRoutes.userChatListScreen),
      ),
      ProfileMenuItem(
        icon: Icons.notifications_rounded,
        label: AppTexts.notifications,
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.userNotificationsScreen),
      ),
      ProfileMenuItem(
        icon: Icons.block_rounded,
        iconColor: AppColors.linkMagenta,
        label: AppTexts.blockedHosts,
        onTap: () => Navigator.pushNamed(context, AppRoutes.blockedUsersScreen),
      ),
      ProfileMenuItem(
        icon: Icons.card_giftcard_rounded,
        iconColor: AppColors.linkMagenta,
        label: AppTexts.referAFriend,
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.referralStatusScreen),
      ),
      ProfileMenuItem(
        icon: Icons.help_rounded,
        label: AppTexts.helpAndSupport,
        onTap: () => ContactUsBottomSheetPresenter.show(context),
      ),
      ProfileMenuItem(
        icon: Icons.settings_rounded,
        label: AppTexts.settings,
        onTap: () => Navigator.pushNamed(context, AppRoutes.settingsScreen),
      ),
    ];
  }
}
