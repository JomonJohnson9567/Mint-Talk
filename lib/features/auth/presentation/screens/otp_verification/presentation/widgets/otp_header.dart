import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class OtpHeader extends StatelessWidget {
  final String phone;
  final String countryCode;

  const OtpHeader({super.key, required this.phone, required this.countryCode});

  String get _formattedPhoneNumber {
    final values = [
      countryCode.trim(),
      phone.trim(),
    ].where((value) => value.isNotEmpty).toList();

    return values.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.verifyYourNumber,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          children: [
            Text(
              AppTexts.sentCodeToNumber,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formattedPhoneNumber,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
