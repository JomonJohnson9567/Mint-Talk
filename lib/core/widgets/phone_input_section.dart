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
  final TextEditingController? controller;

  // Customization fields
  final String? label;
  final TextStyle? labelStyle;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;
  final double? height;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final String? helperText;
  final TextStyle? helperStyle;
  final Color? accentColor;
  final Color? dividerColor;

  const PhoneInputSection({
    super.key,
    required this.selectedCountry,
    required this.onCountryTap,
    required this.onPhoneChanged,
    this.errorText,
    this.controller,
    this.label,
    this.labelStyle,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.height,
    this.textStyle,
    this.hintStyle,
    this.hintText,
    this.helperText,
    this.helperStyle,
    this.accentColor,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label ?? AppTexts.mobileNumber,
            style:
                labelStyle ??
                TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: height ?? 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
                      style: TextStyle(fontSize: 24.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '+${selectedCountry.phoneCode}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: accentColor ?? AppColors.black,
                      ),
                    ),
                    SizedBox(width: 18.w),
                    Icon(
                      AppIcons.arrowDown,
                      size: 18.sp,
                      color: accentColor ?? AppColors.textGrey,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1.w,
                height: 26.h,
                color: dividerColor ?? AppColors.grey.withAlpha(77),
                margin: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  onChanged: onPhoneChanged,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText ?? AppTexts.enterYourPhoneNumber,
                    hintStyle:
                        hintStyle ?? const TextStyle(color: AppColors.textGrey),
                    isDense: true,
                  ),
                  style:
                      textStyle ??
                      TextStyle(
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
        ] else if (helperText != null) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              helperText!,
              style:
                  helperStyle ??
                  TextStyle(color: AppColors.textGrey, fontSize: 12.sp),
            ),
          ),
        ],
      ],
    );
  }
}
