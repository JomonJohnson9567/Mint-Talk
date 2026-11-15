import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';

/// Back chip + "Settings" title block, matching the profile page header.
class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackTitleHeader(
      title: AppTexts.settings,
      subtitle: AppTexts.settingsSubtitle,
    );
  }
}
