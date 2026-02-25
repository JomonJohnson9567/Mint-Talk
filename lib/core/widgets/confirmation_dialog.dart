// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final VoidCallback onConfirm;
  final String cancelButtonText;
  final IconData? icon;
  final Color? iconColor;
  final Color? accentColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmButtonText,
    required this.onConfirm,
    this.cancelButtonText = 'Cancel',
    this.icon,
    this.iconColor,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = this.accentColor ?? AppColors.red;
    final iconColor = this.iconColor ?? accentColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ICON - Circular badge
                  if (icon != null) ...[
                    Container(
                      height: 72.h,
                      width: 72.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            iconColor.withAlpha(31),
                            iconColor.withAlpha(15),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: iconColor.withAlpha(51),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(icon, color: iconColor, size: 32.sp),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  /// TITLE - Refined typography
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  /// CONTENT - Improved readability
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey,
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  /// BUTTONS - Enhanced interaction design
                  Row(
                    children: [
                      /// CANCEL BUTTON
                      Expanded(
                        child: _SecondaryButton(
                          text: cancelButtonText,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      /// CONFIRM BUTTON
                      Expanded(
                        child: _PrimaryButton(
                          text: confirmButtonText,
                          onPressed: onConfirm,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: BorderSide(color: AppColors.grey.withAlpha(77), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.grey,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
