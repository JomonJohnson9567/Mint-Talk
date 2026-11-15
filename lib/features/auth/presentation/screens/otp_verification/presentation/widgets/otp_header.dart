import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class OtpHeader extends StatelessWidget {
  final String phone;
  final String countryCode;

  const OtpHeader({super.key, required this.phone, required this.countryCode});

  /// "+91 9876544821" — the number as entered on the phone screen.
  String get _formattedPhoneNumber {
    final code = countryCode.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    final values = [
      if (code.isNotEmpty) code.startsWith('+') ? code : '+$code',
      digits,
    ].where((value) => value.isNotEmpty).toList();

    return values.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.verifyYourNumber,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 26.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.plumDeep,
            height: 1.1,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          AppTexts.enterCodeSentTo,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.plumMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12.w,
          children: [
            Text(
              _formattedPhoneNumber,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.plumDeep,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              behavior: HitTestBehavior.opaque,
              child: Text(
                AppTexts.change,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.linkMagenta,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.linkMagenta,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
