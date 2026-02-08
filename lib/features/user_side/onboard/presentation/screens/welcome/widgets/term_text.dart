import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        style: TextStyle(color: AppColors.black, fontSize: 14.sp, height: 1.5),
        children: [
          TextSpan(text: AppTexts.bySigningUpYouAgreeToOur),
          TextSpan(
            text: AppTexts.terms,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          TextSpan(text: AppTexts.seeHowWeUseYourDataInOur),
          TextSpan(
            text: AppTexts.termsAndCondition,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, AppRoutes.privacyPolicy);
              },
          ),
        ],
      ),
    );
  }
}
