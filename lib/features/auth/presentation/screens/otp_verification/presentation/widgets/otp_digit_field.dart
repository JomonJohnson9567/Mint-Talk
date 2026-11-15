import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

/// One code box. Display only — typing goes to the hidden field in
/// [OtpInputRow], which owns the whole code.
class OtpDigitField extends StatelessWidget {
  final String digit;
  final bool isActive;
  final bool hasError;

  const OtpDigitField({
    super.key,
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final border = hasError
        ? Border.all(color: AppColors.red, width: 1.5)
        : isActive
        ? Border.all(color: AppColors.plumDeep, width: 2)
        : Border.all(color: AppColors.lavenderBorder, width: 1.5);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 58.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12.r),
        border: border,
      ),
      child: digit.isNotEmpty
          ? Text(
              digit,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.plumDeep,
              ),
            )
          : isActive
          ? Container(width: 2, height: 24.h, color: AppColors.plumDeep)
          : null,
    );
  }
}
