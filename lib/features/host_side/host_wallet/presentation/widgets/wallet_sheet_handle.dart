import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class WalletSheetHandle extends StatelessWidget {
  const WalletSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(999.r),
        ),
      ),
    );
  }
}
