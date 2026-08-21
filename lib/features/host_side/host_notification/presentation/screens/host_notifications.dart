import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/mark_all_read_action.dart';
import 'package:mint_talk/features/shared/notifications/presentation/widgets/notifications_list_body.dart';

class HostNotifications extends StatelessWidget {
  const HostNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Notifications',
        automaticallyImplyLeading: true,
        actions: [MarkAllReadAction()],
      ),
      backgroundColor: AppColors.white,
      body: const NotificationsListBody(),
    );
  }
}
