// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostCallLogSearchBar extends StatelessWidget {
  const HostCallLogSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.grey.withAlpha(40)),
      ),
      child: Row(
        children: [
          SizedBox(width: 16.w),
          Icon(Icons.search, color: AppColors.grey, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                hintStyle: TextStyle(
                  color: AppColors.subtitleText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: AppColors.black,
                fontSize: 14.sp,
              ),
            ),
          ),
          Icon(Icons.close, color: AppColors.grey, size: 20.sp),
          SizedBox(width: 14.w),
        ],
      ),
    );
  }
}
