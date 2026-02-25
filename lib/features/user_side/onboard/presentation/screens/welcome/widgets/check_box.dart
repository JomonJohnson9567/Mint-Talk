import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/welcome/welcome_cubit.dart';

class AgreeCheckboxRow extends StatelessWidget {
  const AgreeCheckboxRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WelcomeCubit, WelcomeState, bool>(
      selector: (state) => state.isAgreed,
      builder: (context, isAgreed) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: isAgreed,
                activeColor: AppColors.primaryColor,
                onChanged: (value) {
                  context.read<WelcomeCubit>().toggleAgreement(value);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                side: BorderSide(color: AppColors.primaryColor, width: 2.w),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.privacyPolicy);
              },
              child: Text(
                AppTexts.agreeTermsAndConditions,
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
