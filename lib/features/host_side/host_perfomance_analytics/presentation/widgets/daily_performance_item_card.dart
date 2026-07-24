import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/color.dart';
import '../../domain/entities/performance_analytics_entity.dart';

class DailyPerformanceItemCard extends StatelessWidget {
  final DailyPerformanceEntity performance;

  const DailyPerformanceItemCard({
    super.key,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Date & Today tag & status icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    performance.date,
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (performance.isToday) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Today',
                        style: GoogleFonts.manrope(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Status check / cancel icon
              Icon(
                performance.targetMet ? Icons.check_circle : Icons.cancel,
                color: performance.targetMet ? AppColors.onlineIndicator : AppColors.callEndedStatus,
                size: 22.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Video & Audio metrics columns
          Row(
            children: [
              Expanded(
                child: _buildColumnInfo(
                  label: 'Video',
                  value: performance.videoMin.toStringAsFixed(2),
                  target: performance.videoTarget.toInt().toString(),
                  color: const Color(0xFF6B4EE0),
                ),
              ),
              Container(width: 1, height: 32.h, color: AppColors.borderSoft),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: _buildColumnInfo(
                    label: 'Audio',
                    value: performance.audioMin.toStringAsFixed(2),
                    target: performance.audioTarget.toInt().toString(),
                    color: AppColors.onlineIndicator,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: AppColors.borderSoft, height: 1),
          SizedBox(height: 12.h),

          // Total aggregate & trend direction
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total  ',
                    style: GoogleFonts.manrope(
                      fontSize: 11.sp,
                      color: AppColors.subtitleText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    performance.totalMin.toStringAsFixed(1),
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    ' /${performance.totalTarget.toInt()}',
                    style: GoogleFonts.manrope(
                      fontSize: 11.sp,
                      color: AppColors.subtitleText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Trend icon
              Icon(
                performance.trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: performance.targetMet ? AppColors.onlineIndicator : AppColors.callEndedStatus,
                size: 18.sp,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumnInfo({
    required String label,
    required String value,
    required String target,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11.sp,
            color: AppColors.subtitleText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              ' /$target',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                color: AppColors.subtitleText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
