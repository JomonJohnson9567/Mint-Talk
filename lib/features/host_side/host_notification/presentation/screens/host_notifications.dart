import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_mascot_banner.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_segmented_toggle.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/mark_all_read_action.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/notifications_list_body.dart';

class HostNotifications extends StatelessWidget {
  const HostNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: const CustomAppBar(
        title: AppTexts.notifications,
        automaticallyImplyLeading: true,
        foregroundColor: AppColors.plumDeep,
        actions: [MarkAllReadAction()],
      ),
      body: SafeArea(
        bottom: false,
        child: NotificationsListBody(
          header: const HostMascotBanner(
            title: AppTexts.stayInTheLoop,
            subtitle: AppTexts.updatesForHostingJourney,
            // The greeting mascot is opaque on hostGreetingBanner (default).
            mascotAsset: AppAssets.hostGreetingMascot,
            mascotHeight: 92,
          ),
          filterBuilder: (unreadOnly, onChanged) => HostSegmentedToggle(
            labels: const [AppTexts.filterAll, AppTexts.filterUnread],
            selectedIndex: unreadOnly ? 1 : 0,
            onChanged: (index) => onChanged(index == 1),
          ),
        ),
      ),
    );
  }
}
