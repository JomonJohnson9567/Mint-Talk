import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for the [ApplyForHost] screen while profile data loads.
class ApplyForHostSkeleton extends StatelessWidget {
  const ApplyForHostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(
              width: 220.w,
              height: 22.h,
              borderRadius: BorderRadius.circular(6.r),
            ),
            SizedBox(height: 8.h),
            SkeletonBox(
              width: 280.w,
              height: 14.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
            SizedBox(height: 6.h),
            SkeletonBox(
              width: 200.w,
              height: 14.h,
              borderRadius: BorderRadius.circular(4.r),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const _FormFieldSkeleton(labelWidth: 80, height: 56),
                    SizedBox(height: 20.h),
                    const _FormFieldSkeleton(labelWidth: 90, height: 56),
                    SizedBox(height: 20.h),
                    const _FormFieldSkeleton(labelWidth: 40, height: 100),
                    SizedBox(height: 24.h),
                    const _SelfieUploadSkeleton(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
            SkeletonBox(
              width: double.infinity,
              height: 52.h,
              borderRadius: BorderRadius.circular(30.r),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _FormFieldSkeleton extends StatelessWidget {
  final double labelWidth;
  final double height;

  const _FormFieldSkeleton({
    required this.labelWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: labelWidth.w,
          height: 12.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        SizedBox(height: 8.h),
        SkeletonBox(
          width: double.infinity,
          height: height.h,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ],
    );
  }
}

class _SelfieUploadSkeleton extends StatelessWidget {
  const _SelfieUploadSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: 100.w,
          height: 12.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        SizedBox(height: 8.h),
        SkeletonBox(
          width: double.infinity,
          height: 130.h,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ],
    );
  }
}
