import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class ReasonInputField extends StatelessWidget {
  final String reason;
  final ValueChanged<String> onChanged;

  const ReasonInputField({
    super.key,
    required this.reason,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Leave',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          height: 120.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FC),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.primaryColor,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Please provide a brief explanation...',
                    hintStyle: TextStyle(
                      color: AppColors.subtitleText,
                      fontWeight: FontWeight.normal,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
