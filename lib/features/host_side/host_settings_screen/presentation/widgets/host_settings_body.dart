import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/about/presentation/screen/about.dart';
import 'package:mint_talk/features/host_side/chat/presentation/screen/host_chat_list_screen.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/host_contact_us_bottom_sheet.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/host_settings_profile_card.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/settings_tile.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/screen/host_wallet.dart';
import 'package:mint_talk/features/host_side/privacy_policy/presentation/screen/privacy_policy.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'package:mint_talk/features/host_side/terms_and_conditions/presentation/screen/terms_and_conditions.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_action_bottom_sheet.dart';

import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/host_settings_skeleton.dart';

class HostSettingsBody extends StatelessWidget {
  final bool isLoading;

  const HostSettingsBody({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const HostSettingsSkeleton();
    }

    final items = <_SettingsItem>[
      _SettingsItem(
        icon: Icons.account_balance_wallet_outlined,
        title: AppTexts.hostWallet,
        subtitle: AppTexts.balanceAndWithdrawals,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HostWallet())),
      ),
      _SettingsItem(
        icon: Icons.bar_chart_rounded,
        title: AppTexts.earningsLedger,
        subtitle: AppTexts.minutesAndWeeklyEarnings,
        onTap: () =>
            getIt<NavigationService>().navigateTo(AppRoutes.hostAnalytics),
      ),
      _SettingsItem(
        icon: Icons.call_outlined,
        title: AppTexts.conversations,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HostChatListScreen())),
      ),
      _SettingsItem(
        icon: Icons.notifications_none_rounded,
        title: AppTexts.notifications,
        onTap: () => getIt<NavigationService>().navigateTo(
          AppRoutes.hostNotificationsScreen,
        ),
      ),
      _SettingsItem(
        icon: Icons.calendar_today_outlined,
        title: AppTexts.leaveRequest,
        onTap: () =>
            getIt<NavigationService>().navigateTo(AppRoutes.applyForLeave),
      ),
      _SettingsItem(
        icon: Icons.help_outline_rounded,
        title: AppTexts.helpAndSupport,
        onTap: () => HostContactUsBottomSheetPresenter.show(context),
      ),
      _SettingsItem(
        icon: Icons.shield_outlined,
        title: AppTexts.blockedUsers,
        onTap: () => getIt<NavigationService>().navigateTo(
          AppRoutes.hostBlockedUsersScreen,
        ),
      ),
      _SettingsItem(
        icon: Icons.description_outlined,
        title: AppTexts.termsConditions,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TermsAndConditions())),
      ),
      _SettingsItem(
        icon: Icons.privacy_tip_outlined,
        title: AppTexts.privacyPolicy,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicy())),
      ),
      _SettingsItem(
        icon: Icons.info_outline_rounded,
        title: AppTexts.about,
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
      ),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(16.cw, 8.cw, 16.cw, 24.cw),
      children: [
        const HostSettingsProfileCard(),
        SizedBox(height: 10.cw),
        for (var i = 0; i < items.length; i++)
          SettingsTile(
            icon: items[i].icon,
            tint: HostIconTint.alternating(i),
            title: items[i].title,
            subtitle: items[i].subtitle,
            onTap: items[i].onTap,
          ),
        SettingsTile(
          icon: Icons.logout_rounded,
          title: AppTexts.logOut,
          isDestructive: true,
          onTap: () {
            final logoutCubit = context.read<LogoutCubit>();
            SettingsActionBottomSheetPresenter.showLogout(
              context,
              onConfirm: logoutCubit.logout,
            );
          },
        ),
        // Clears the floating bottom nav bar.
        SizedBox(height: 90.cw),
      ],
    );
  }
}

class _SettingsItem {
  final VoidCallback? onTap;
  final IconData icon;
  final String title;
  final String? subtitle;

  const _SettingsItem({
    required this.onTap,
    required this.icon,
    required this.title,
    this.subtitle,
  });
}
