import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [LeaveHistoryList] while history loads.
class LeaveHistorySkeleton extends StatelessWidget {
  const LeaveHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE7EBF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkeletonBox(width: 36.w, height: 36.w, shape: BoxShape.circle),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 140.w, height: 13.h),
                        SizedBox(height: 6.h),
                        SkeletonBox(width: 80.w, height: 11.h),
                      ],
                    ),
                  ),
                  SkeletonBox(
                    width: 60.w,
                    height: 20.h,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SkeletonBox(width: double.infinity, height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}
