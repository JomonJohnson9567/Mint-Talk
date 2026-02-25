import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_tile.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';

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
            onTap: () {},
          ),
          //terms and conditions
          ProfileTile(
            icon: Icons.description,
            iconColor: AppColors.termsIcon,
            iconBackgroundColor: AppColors.termsIcon.withValues(alpha: 0.2),
            title: AppTexts.termsConditions,
            onTap: () {},
          ),

          ProfileTile(
            icon: Icons.logout,
            iconColor: AppColors.favIcon,
            iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
            title: AppTexts.logout,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ConfirmationDialog(
                    title: AppTexts.logout,
                    content: AppTexts.logoutMessage,
                    confirmButtonText: AppTexts.logout,
                    onConfirm: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
          //delete account
          ProfileTile(
            icon: Icons.delete_forever_outlined,
            iconColor: AppColors.favIcon,
            iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
            title: AppTexts.deleteAccount,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return ConfirmationDialog(
                    title: AppTexts.deleteAccount,
                    content: AppTexts.deleteAccountMessage,
                    confirmButtonText: "Delete",
                    onConfirm: () {
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
