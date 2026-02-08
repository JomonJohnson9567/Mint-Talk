// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/custom_outline_button.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomOutlineButton(
              onPressed: () {
                Navigator.pop(context);
              },
              text: AppTexts.decline,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: PrimaryButton(
              onPressed: () {
                Navigator.pop(context);
              },
              text: AppTexts.agreeAndContinue,
            ),
          ),
        ],
      ),
    );
  }
}
