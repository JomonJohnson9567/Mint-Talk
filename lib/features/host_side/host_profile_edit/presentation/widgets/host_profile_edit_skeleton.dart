import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [HostProfileEdit] while the profile
/// data loads. Mirrors [HostProfileEditContents]'s avatar + field layout.
class HostProfileEditSkeleton extends StatelessWidget {
  const HostProfileEditSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SkeletonBox(
                width: 96.w,
                height: 96.w,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 24.h),
            ...List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 100.w, height: 12.h),
                    SizedBox(height: 8.h),
                    SkeletonBox(
                      width: double.infinity,
                      height: 52.h,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ],
                ),
              ),
            ),
            SkeletonBox(width: 140.w, height: 14.h),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: List.generate(
                4,
                (index) => SkeletonBox(
                  width: 90.w,
                  height: 36.h,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
            SizedBox(height: 40.h),
            SkeletonBox(
              width: double.infinity,
              height: 52.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
