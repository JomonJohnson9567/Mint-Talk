import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostProfileAvatar extends StatelessWidget {
  const HostProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primaryColor.withAlpha(26),
                width: 4,
              ),
              color: AppColors.lightGrey,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60.w),
              child: Image.asset(
                AppAssets.femaleIcon,
                fit: BoxFit.cover,
                width: 120.w,
                height: 120.w,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.edit, color: AppColors.white, size: 20.w),
            ),
          ),
        ],
      ),
    );
  }
}
