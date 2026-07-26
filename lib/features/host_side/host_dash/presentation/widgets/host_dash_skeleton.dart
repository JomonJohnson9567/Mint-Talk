import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

class HostDashSkeleton extends StatelessWidget {
  const HostDashSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w).copyWith(bottom: 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            // Header skeleton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140.w, height: 18.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 90.w, height: 14.h),
                  ],
                ),
                SkeletonBox(
                  width: 44.w,
                  height: 44.h,
                  shape: BoxShape.circle,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Welcome Card skeleton
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE7EBF3)),
              ),
              child: Row(
                children: [
                  SkeletonBox(
                    width: 60.r,
                    height: 60.r,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120.w, height: 16.h),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            SkeletonBox(width: 70.w, height: 24.h),
                            SizedBox(width: 8.w),
                            SkeletonBox(width: 80.w, height: 24.h),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Select Call Card skeleton
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
                  SkeletonBox(width: 160.w, height: 16.h),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: SkeletonBox(height: 50.h)),
                      SizedBox(width: 12.w),
                      Expanded(child: SkeletonBox(height: 50.h)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SkeletonBox(width: double.infinity, height: 48.h),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Online Hosts section skeleton
            SkeletonBox(width: 130.w, height: 16.h),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                4,
                (index) => Column(
                  children: [
                    SkeletonBox(
                      width: 56.r,
                      height: 56.r,
                      shape: BoxShape.circle,
                    ),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 48.w, height: 12.h),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Promo Banner skeleton
            SkeletonBox(
              width: double.infinity,
              height: 110.h,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ],
        ),
      ),
    );
  }
}
