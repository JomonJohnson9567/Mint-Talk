import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/color.dart';

class SummaryItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String valueText;
  final Color valueTextColor;
  final String durationText;
  final IconData trendIcon;
  final Color trendColor;

  const SummaryItemCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.valueText,
    required this.valueTextColor,
    required this.durationText,
    required this.trendIcon,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          SizedBox(width: 14.w),

          // Main Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.subtitleText,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  valueText,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: valueTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Right indicator side (Duration text + Trend icon)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                durationText,
                style: GoogleFonts.manrope(
                  fontSize: 11.sp,
                  color: AppColors.subtitleText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Icon(trendIcon, color: trendColor, size: 18.sp),
            ],
          ),
        ],
      ),
    );
  }
}
