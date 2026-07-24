import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WalletTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool textCapitalizationWords;

  const WalletTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.initialValue,
    this.textCapitalizationWords = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          textCapitalization:
              textCapitalizationWords ? TextCapitalization.words : TextCapitalization.none,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 13.sp,
              color: AppColors.subtitleText.withValues(alpha: 0.7),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: AppColors.borderSoft, width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide(color: AppColors.borderSoft, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
