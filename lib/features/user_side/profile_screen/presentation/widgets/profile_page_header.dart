import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// "My profile" title block with the settings shortcut.
class ProfilePageHeader extends StatelessWidget {
  const ProfilePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.myProfile,
                style: GoogleFonts.nunito(
                  fontSize: 28.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 2.cw),
              Text(
                AppTexts.profileSubtitle,
                style: TextStyle(
                  fontSize: 13.csp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.plumMuted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.settingsScreen),
          tooltip: AppTexts.settings,
          icon: Icon(
            Icons.settings_outlined,
            size: 26.csp,
            color: AppColors.plumDeep,
          ),
        ),
      ],
    );
  }
}
