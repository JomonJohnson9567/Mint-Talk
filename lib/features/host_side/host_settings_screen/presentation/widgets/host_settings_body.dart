import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/features/host_side/about/presentation/screen/about.dart';
import 'package:mint_talk/features/host_side/block_users/presentation/screen/blocked_users.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/host_contact_us_bottom_sheet.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/settings_tile.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/screen/host_wallet.dart';
import 'package:mint_talk/features/host_side/privacy_policy/presentation/screen/privacy_policy.dart';
import 'package:mint_talk/features/host_side/terms_and_conditions/presentation/screen/terms_and_conditions.dart';

class HostSettingsBody extends StatelessWidget {
  const HostSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_SettingsItem>[
      _SettingsItem(
        icon: Icons.account_balance_wallet_rounded,
        iconColor: Colors.white,
        iconBgColor: const Color(0xFF4A52DA),
        title: 'Wallet',
        subtitle: 'Manage your balance & transactions',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const HostWallet())),
      ),
      _SettingsItem(
        icon: Icons.calendar_month_rounded,
        iconColor: const Color(0xFF2DB37B),
        iconBgColor: const Color(0xFFE8F8F0),
        title: 'Leave Request',
        subtitle: 'Request and track your leaves',
        onTap: () => getIt<NavigationService>().navigateTo(AppRoutes.applyForLeave),
      ),
      _SettingsItem(
        icon: Icons.headset_mic_rounded,
        iconColor: const Color(0xFF43A047),
        iconBgColor: const Color(0xFFEAF8F0),
        title: 'Contact Us',
        subtitle: 'Get in touch with our support team',
        onTap: () => HostContactUsBottomSheetPresenter.show(context),
      ),
      _SettingsItem(
        icon: Icons.block_rounded,
        iconColor: const Color(0xFFE53935),
        iconBgColor: const Color(0xFFFFEBEE),
        title: 'Blocked Users',
        subtitle: "Manage users you've blocked",
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const BlockedUsers())),
      ),
      _SettingsItem(
        icon: Icons.description_rounded,
        iconColor: const Color(0xFF4A52DA),
        iconBgColor: const Color(0xFFEEF0FF),
        title: 'Terms & Conditions',
        subtitle: 'Read our terms and policies',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TermsAndConditions())),
      ),
      _SettingsItem(
        icon: Icons.privacy_tip_rounded,
        iconColor: const Color(0xFF00897B),
        iconBgColor: const Color(0xFFE0F2F1),
        title: 'Privacy Policy',
        subtitle: 'How we handle your data',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PrivacyPolicy())),
      ),
      _SettingsItem(
        icon: Icons.info_rounded,
        iconColor: const Color(0xFF1E88E5),
        iconBgColor: const Color(0xFFE3F2FD),
        title: 'About',
        subtitle: 'App version and information',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
      ),
    ];

    return ListView(
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      children: [
        ...items.map(
          (item) => SettingsTile(
            icon: item.icon,
            iconColor: item.iconColor,
            iconBgColor: item.iconBgColor,
            title: item.title,
            subtitle: item.subtitle,
            onTap: item.onTap,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final VoidCallback? onTap;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _SettingsItem({
    required this.onTap,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });
}
