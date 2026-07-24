import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/color.dart';
import '../../domain/entities/performance_analytics_entity.dart';

class TodayPerformanceCard extends StatelessWidget {
  final PerformanceAnalyticsEntity analytics;

  const TodayPerformanceCard({
    super.key,
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Today, 25 Jan
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                analytics.todayDateLabel,
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Video Calls row
          _buildCallProgressRow(
            context: context,
            title: 'Video Calls',
            currentMinutes: analytics.todayVideoMin,
            targetMinutes: analytics.todayVideoTarget,
            percentage: analytics.todayVideoPercentage,
            icon: Icons.videocam_rounded,
            iconColor: AppColors.primaryColor,
            iconBgColor: AppColors.primaryColor.withAlpha(20),
            gradientColors: [const Color(0xFF6B4EE0), const Color(0xFF9075F3)],
            badgeBgColor: const Color(0xFFF0ECFC),
            badgeTextColor: const Color(0xFF6B4EE0),
          ),

          SizedBox(height: 16.h),
          const Divider(color: AppColors.borderSoft, height: 1),
          SizedBox(height: 16.h),

          // Audio Calls row
          _buildCallProgressRow(
            context: context,
            title: 'Audio Calls',
            currentMinutes: analytics.todayAudioMin,
            targetMinutes: analytics.todayAudioTarget,
            percentage: analytics.todayAudioPercentage,
            icon: Icons.phone_rounded,
            iconColor: AppColors.onlineIndicator,
            iconBgColor: AppColors.onlineIndicator.withAlpha(20),
            gradientColors: [const Color(0xFF18A957), const Color(0xFF4EE08E)],
            badgeBgColor: const Color(0xFFE8F8EE),
            badgeTextColor: const Color(0xFF18A957),
          ),

          SizedBox(height: 20.h),

          // Status Banner (Target Missed)
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: analytics.todayTargetMet
                  ? AppColors.onlineIndicator.withAlpha(15)
                  : AppColors.callEndedStatus.withAlpha(15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: analytics.todayTargetMet
                    ? AppColors.onlineIndicator.withAlpha(60)
                    : AppColors.callEndedStatus.withAlpha(60),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.track_changes_rounded,
                  color: analytics.todayTargetMet
                      ? AppColors.onlineIndicator
                      : AppColors.callEndedStatus,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  analytics.todayTargetMet ? 'Target Achieved' : 'Target Missed',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: analytics.todayTargetMet
                        ? AppColors.onlineIndicator
                        : AppColors.callEndedStatus,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallProgressRow({
    required BuildContext context,
    required String title,
    required double currentMinutes,
    required double targetMinutes,
    required double percentage,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required List<Color> gradientColors,
    required Color badgeBgColor,
    required Color badgeTextColor,
  }) {
    final progressFraction = targetMinutes > 0 ? (currentMinutes / targetMinutes) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Icon Background
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${currentMinutes.toStringAsFixed(2)} Min',
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Target right-aligned
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${targetMinutes.toInt()} Min',
                  style: GoogleFonts.manrope(
                    fontSize: 11.sp,
                    color: AppColors.subtitleText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(2)}%',
                    style: GoogleFonts.manrope(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Gradient Progress Bar
        _GradientProgressBar(
          progress: progressFraction,
          colors: gradientColors,
        ),
      ],
    );
  }
}

class _GradientProgressBar extends StatelessWidget {
  final double progress;
  final List<Color> colors;

  const _GradientProgressBar({
    required this.progress,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double calculatedWidth = constraints.maxWidth * progress.clamp(0.0, 1.0);
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: calculatedWidth,
              height: 8.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          );
        },
      ),
    );
  }
}
