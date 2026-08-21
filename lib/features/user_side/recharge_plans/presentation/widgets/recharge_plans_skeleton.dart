import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for the plan list in [ScreenContents]
/// while [WalletCubit] fetches plans.
class RechargePlansSkeleton extends StatelessWidget {
  const RechargePlansSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonBox(width: 140.w, height: 16.h),
          SizedBox(height: 14.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.3,
            children: List.generate(
              4,
              (index) => SkeletonBox(borderRadius: BorderRadius.circular(20.r)),
            ),
          ),
        ],
      ),
    );
  }
}
