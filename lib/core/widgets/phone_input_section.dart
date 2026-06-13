// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:country_picker/country_picker.dart';

class PhoneInputSection extends StatelessWidget {
  final Country selectedCountry;
  final VoidCallback onCountryTap;
  final ValueChanged<String> onPhoneChanged;
  final String? errorText;

  // Customization fields
  final String? label;
  final TextStyle? labelStyle;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;
  final double? height;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const PhoneInputSection({
    super.key,
    required this.selectedCountry,
    required this.onCountryTap,
    required this.onPhoneChanged,
    this.errorText,
    this.label,
    this.labelStyle,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.textStyle,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label ?? AppTexts.mobileNumber,
          style: labelStyle ?? TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: height ?? 50.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.grey.withAlpha(153),
            border: border,
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onCountryTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      selectedCountry.flagEmoji,
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '+${selectedCountry.phoneCode}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      AppIcons.arrowDown,
                      size: 16.sp,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.w,
                height: 24.h,
                color: AppColors.grey.withAlpha(77),
                margin: EdgeInsets.symmetric(horizontal: 12.w),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  onChanged: onPhoneChanged,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppTexts.enterYourPhoneNumber,
                    hintStyle: hintStyle ?? const TextStyle(color: AppColors.textGrey),
                    isDense: true,
                  ),
                  style: textStyle ?? TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 5.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
        ],
      ],
    );
  }
}
