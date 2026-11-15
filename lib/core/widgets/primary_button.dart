import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double width;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final IconData? trailingIcon;
  final double? height;
  final TextStyle? textStyle;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;

  const PrimaryButton({
    super.key,
    this.onPressed,
    required this.text,
    this.width = double.infinity,
    this.backgroundColor = AppColors.primaryColor,
    this.foregroundColor = AppColors.white,
    this.isLoading = false,
    this.trailingIcon,
    this.height,
    this.textStyle,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style:
          textStyle ?? TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          disabledForegroundColor: disabledForegroundColor,
          padding: height == null
              ? EdgeInsets.symmetric(vertical: 16.h)
              : EdgeInsets.symmetric(horizontal: 20.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          elevation: 0,
          side: onPressed == null && disabledBackgroundColor == null
              ? const BorderSide(color: AppColors.grey)
              : null,
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: onPressed == null
                      ? disabledForegroundColor ?? foregroundColor
                      : foregroundColor,
                ),
              )
            : trailingIcon == null
            ? label
            : Stack(
                alignment: Alignment.center,
                children: [
                  label,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(trailingIcon, size: 22.sp),
                  ),
                ],
              ),
      ),
    );
  }
}
