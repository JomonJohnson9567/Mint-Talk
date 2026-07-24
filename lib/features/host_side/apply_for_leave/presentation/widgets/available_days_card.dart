import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';

class AvailableDaysCard extends StatelessWidget {
  final int availableDays;
  final int totalDays;

  const AvailableDaysCard({
    super.key,
    required this.availableDays,
    this.totalDays = 15,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (availableDays / totalDays).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // soft green background
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7), // green icon background
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.onlineIndicator,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Days',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'You can avail up to',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.subtitleText,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$availableDays',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onlineIndicator,
                    ),
                  ),
                  Text(
                    'Days',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.subtitleText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFE2E8F0),
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
