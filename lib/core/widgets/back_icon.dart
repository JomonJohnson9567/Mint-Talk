// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class PopBackIcon extends StatelessWidget {
  const PopBackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grey.withOpacity(0.6),
        ),
        child: Icon(Icons.arrow_back, color: AppColors.black, size: 24.sp),
      ),
    );
  }
}
