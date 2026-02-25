import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_avatar.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_tile.dart';
 
class ProfileContents extends StatelessWidget {
  const ProfileContents({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Column(
        children: [
          const ProfileAvatar(),
          SizedBox(height: 24.h),
          ProfileTile(
            icon: Icons.edit,
            iconColor: AppColors.primaryColor,
            iconBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.2),
            title: AppTexts.editProfile,
            onTap: () {},
          ),

          //blocked users
          ProfileTile(
            icon: Icons.block,
            iconColor: AppColors.favIcon,
            iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
            title: AppTexts.blockedUsers,
            onTap: () {},
          ),
          //referral code
          ProfileTile(
            icon: Icons.card_giftcard,
            iconColor: AppColors.favIcon,
            iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
            title: AppTexts.referralCode,
            onTap: () {},
          ),
          ProfileTile(
            icon: Icons.settings,
            iconColor: AppColors.grey,
            iconBackgroundColor: AppColors.grey.withValues(alpha: 0.2),
            title: AppTexts.settings,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.settingsScreen);
            },
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
