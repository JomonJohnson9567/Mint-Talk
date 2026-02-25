import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _UserAvatarSection(),
        SizedBox(height: 16.h),
        const _UserInfoSection(),
        SizedBox(height: 32.h),
        const _ApplyHostButton(),
      ],
    );
  }
}

class _UserAvatarSection extends StatelessWidget {
  const _UserAvatarSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.green.withValues(alpha: 0.2),
              width: 12.w,
            ),
          ),
          child: CircleAvatar(
            radius: 50.r,
            backgroundColor: AppColors.grey.withValues(alpha: 0.1),
            backgroundImage: const AssetImage(AppAssets.femaleIcon),
          ),
        ),
        Positioned(
          bottom: 15.h, 
          right: 15.w,
          child: Container(
            height: 16.h,
            width: 16.h,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2.w),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Jommon Kuttikatil",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "+91 9567462733",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}

class _ApplyHostButton extends StatelessWidget {
  const _ApplyHostButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 66.h,
      decoration: BoxDecoration(
        color: AppColors.chatIcon,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.chatIcon.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                _buildButtonIcon(),
                SizedBox(width: 16.w),
                Text(
                  AppTexts.becomeAHost,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.white,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonIcon() {
    return Container(
      height: 40.h,
      width: 40.h,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Icon(
          Icons.person_add_outlined,
          color: AppColors.white,
          size: 20.sp,
        ),
      ),
    );
  }
}
