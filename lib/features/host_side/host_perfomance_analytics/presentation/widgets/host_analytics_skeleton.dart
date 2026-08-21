import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [HostAnalytics] while the earnings
/// ledger loads. Mirrors the header + summary grid + ledger list layout.
class HostAnalyticsSkeleton extends StatelessWidget {
  const HostAnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SkeletonBox(width: 40.w, height: 40.w, shape: BoxShape.circle),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 150.w, height: 18.h),
                      SizedBox(height: 6.h),
                      SkeletonBox(width: 220.w, height: 12.h),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.18,
              children: List.generate(
                4,
                (index) => SkeletonBox(borderRadius: BorderRadius.circular(16.r)),
              ),
            ),
            SizedBox(height: 20.h),
            SkeletonBox(width: 150.w, height: 16.h),
            SizedBox(height: 12.h),
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: SkeletonBox(
                  height: 64.h,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
