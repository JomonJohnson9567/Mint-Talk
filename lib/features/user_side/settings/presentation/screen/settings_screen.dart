import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_contents.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(child: SettingsContents()),
    );
  }
}
