import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [PlanDetailScreen] while the plan
/// loads. Mirrors the hero card + benefits + payment summary layout.
class PlanDetailSkeleton extends StatelessWidget {
  const PlanDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 260.h, borderRadius: BorderRadius.circular(32.r)),
            SizedBox(height: 24.h),
            SkeletonBox(width: 140.w, height: 18.h),
            SizedBox(height: 16.h),
            SkeletonBox(height: 60.h, borderRadius: BorderRadius.circular(20.r)),
            SizedBox(height: 12.h),
            SkeletonBox(height: 60.h, borderRadius: BorderRadius.circular(20.r)),
            SizedBox(height: 24.h),
            SkeletonBox(height: 160.h, borderRadius: BorderRadius.circular(28.r)),
            SizedBox(height: 32.h),
            SkeletonBox(height: 56.h, borderRadius: BorderRadius.circular(20.r)),
          ],
        ),
      ),
    );
  }
}
