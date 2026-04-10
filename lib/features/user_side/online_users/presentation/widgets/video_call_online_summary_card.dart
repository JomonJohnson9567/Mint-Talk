import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';

class VideoCallOnlineSummaryCard extends StatelessWidget {
  final int onlineCount;
  final int topRatedCount;
  final int instantJoinCount;

  const VideoCallOnlineSummaryCard({
    super.key,
    required this.onlineCount,
    required this.topRatedCount,
    required this.instantJoinCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.tealBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withAlpha(70),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(46),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.videocam_rounded,
                  color: AppColors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  AppTexts.videoCall,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            AppTexts.videoCallHostsOnline,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '$onlineCount ${AppTexts.hostsLiveNow} | ${AppTexts.readyToConnect}',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.white.withAlpha(220),
              height: 1.5,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _SummaryMetric(
                  value: onlineCount.toString(),
                  label: AppTexts.availableNow,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  value: topRatedCount.toString(),
                  label: AppTexts.topRated,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SummaryMetric(
                  value: instantJoinCount.toString(),
                  label: AppTexts.instantJoin,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(32),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.white.withAlpha(46)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }
}
