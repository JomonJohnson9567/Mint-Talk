import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';

class ProfileLogo extends StatelessWidget {
  const ProfileLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          image: DecorationImage(
            image: AssetImage(AppAssets.profileSetupLogo),
            fit: BoxFit.cover,
          ),
        ),
        height: 50.h,
        width: 200.w,
      ),
    );
  }
}
