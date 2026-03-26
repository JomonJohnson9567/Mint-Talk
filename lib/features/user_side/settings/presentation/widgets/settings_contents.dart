import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/contact_us_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_action_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_tile.dart';

class SettingsContents extends StatelessWidget {
  const SettingsContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          //contact uss
          ProfileTile(
            icon: Icons.email,
            iconColor: AppColors.contactIcon,
            iconBackgroundColor: AppColors.contactIcon.withValues(alpha: 0.2),
            title: AppTexts.contactUs,
            onTap: () => ContactUsBottomSheetPresenter.show(context),
          ),
          //terms and conditions
          ProfileTile(
            icon: Icons.description,
            iconColor: AppColors.termsIcon,
            iconBackgroundColor: AppColors.termsIcon.withValues(alpha: 0.2),
            title: AppTexts.termsConditions,
            onTap: () {},
          ),
          //About us
          ProfileTile(
            icon: Icons.info,
            iconColor: AppColors.aboutIcon,
            iconBackgroundColor: AppColors.aboutIcon.withValues(alpha: 0.2),
            title: AppTexts.aboutUs,
            onTap: () {},
          ),
          //logout
          ProfileTile(
            icon: Icons.logout,
            iconColor: AppColors.favIcon,
            iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
            title: AppTexts.logout,
            onTap: () => SettingsActionBottomSheetPresenter.showLogout(
              context,
              onConfirm: () {},
            ),
          ),
          //delete account
          ProfileTile(
            icon: Icons.delete_forever_outlined,
            iconColor: AppColors.favIcon,
            iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
            title: AppTexts.deleteAccount,
            onTap: () => SettingsActionBottomSheetPresenter.showDeleteAccount(
              context,
              onConfirm: () {},
            ),
          ),
        ],
      ),
    );
  }
}
