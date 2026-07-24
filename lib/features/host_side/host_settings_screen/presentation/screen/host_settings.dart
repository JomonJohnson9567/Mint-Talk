import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/host_settings_body.dart';

class HostSettings extends StatelessWidget {
  const HostSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'Settings',
        automaticallyImplyLeading: false,
      ),
      body: HostSettingsBody(),
    );
  }
}