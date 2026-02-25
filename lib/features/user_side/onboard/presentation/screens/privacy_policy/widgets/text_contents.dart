import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/widgets/action_buttons.dart';

class TextContents extends StatelessWidget {
  const TextContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.introduction,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppTexts.introductionContent,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  AppTexts.termsofUse,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppTexts.termsofUseContent,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  AppTexts.privacyPolicy,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppTexts.privacyPolicyContent,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  AppTexts.userResponsibilities,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppTexts.userResponsibilitiesContent,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  AppTexts.intellectualProperty,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppTexts.intellectualPropertyContent,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        ActionButtons(),
      ],
    );
  }
}
