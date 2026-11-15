import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

/// Plum-styled labelled field for the user profile setup screen. Kept
/// separate from the shared `ProfileField`, which the host setup and edit
/// screens still use in their original style.
class SetupTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final String? errorText;
  final String? initialValue;
  final Color? labelColor;
  final AutovalidateMode? autovalidateMode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  const SetupTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.onChanged,
    this.errorText,
    this.initialValue,
    this.labelColor,
    this.autovalidateMode,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: labelColor ?? AppColors.plumDeep,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          validator: validator,
          autovalidateMode: autovalidateMode,
          onChanged: onChanged,
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          cursorColor: AppColors.primaryColor,
          decoration: InputDecoration(
            errorText: errorText,
            errorStyle: TextStyle(fontSize: 12.sp, color: Colors.red.shade700),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.plumHint,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20.sp, color: AppColors.primaryColor),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 15.h,
            ),
            border: border(AppColors.lavenderBorder),
            enabledBorder: border(AppColors.lavenderBorder),
            focusedBorder: border(AppColors.primaryColor),
            errorBorder: border(Colors.red.shade700),
            focusedErrorBorder: border(Colors.red.shade700),
            suffixIcon: suffixIcon,
          ),
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.plumDeep,
          ),
        ),
      ],
    );
  }
}
