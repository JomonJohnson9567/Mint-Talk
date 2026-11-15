import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/mark_all_read_action.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/notifications_list_body.dart';

class UserNotifications extends StatelessWidget {
  const UserNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.rechargeBackground,
      appBar: CustomAppBar(
        title: AppTexts.notifications,
        automaticallyImplyLeading: true,
        centerTitle: false,
        foregroundColor: AppColors.plumDeep,
        actions: [MarkAllReadAction()],
      ),
      body: SafeArea(bottom: false, child: NotificationsListBody()),
    );
  }
}
