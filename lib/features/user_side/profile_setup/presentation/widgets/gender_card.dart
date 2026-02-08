import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/theme/color.dart';

class GenderCard extends StatelessWidget {
  final String label;
  final String iconPath; // Or IconData if using icons
  final bool isSelected;
  final VoidCallback onTap;

  const GenderCard({
    super.key,
    required this.label,
    required this.iconPath, // Passing image path or icon
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryPurple
                : AppColors.grey.withOpacity(0.8),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primaryPurple.withOpacity(0.5)
                  : AppColors.grey.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.h),
                  child: ClipOval(
                    child: Container(
                      height: 80.h,
                      width: 80.h,
                      color: AppColors.grey.withOpacity(0.1),
                      child: Image.asset(
                        label == 'Male'
                            ? AppAssets.maleIcon
                            : AppAssets.femaleIcon,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(4.sp),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryPurple,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 12.sp,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
