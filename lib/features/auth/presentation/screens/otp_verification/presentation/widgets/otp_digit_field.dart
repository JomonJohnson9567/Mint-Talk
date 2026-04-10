import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class OtpDigitField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;

  const OtpDigitField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.textInputAction,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: hasError
              ? AppColors.red
              : AppColors.primaryColor.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        textInputAction: textInputAction,
        maxLength: 1,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 16.sp, color: AppColors.black),
        onChanged: onChanged,
      ),
    );
  }
}
