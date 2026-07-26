import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

class HostProfileSkeleton extends StatelessWidget {
  const HostProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16.h),
          // Profile Header Skeleton
          Center(
            child: Column(
              children: [
                SkeletonBox(
                  width: 90.r,
                  height: 90.r,
                  shape: BoxShape.circle,
                ),
                SizedBox(height: 12.h),
                SkeletonBox(width: 150.w, height: 20.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 110.w, height: 14.h),
                SizedBox(height: 8.h),
                SkeletonBox(width: 90.w, height: 22.h),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Stats Row Skeleton
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 70.h)),
              SizedBox(width: 12.w),
              Expanded(child: SkeletonBox(height: 70.h)),
              SizedBox(width: 12.w),
              Expanded(child: SkeletonBox(height: 70.h)),
            ],
          ),
          SizedBox(height: 24.h),

          // Info Section Skeleton
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE7EBF3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 120.w, height: 18.h),
                    SkeletonBox(width: 40.w, height: 18.h),
                  ],
                ),
                SizedBox(height: 16.h),
                ...List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SkeletonBox(width: 90.w, height: 14.h),
                        SkeletonBox(width: 110.w, height: 14.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Action Buttons Skeleton
          SkeletonBox(width: double.infinity, height: 48.h),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
