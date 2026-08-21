import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [ReferralStatusContents] while the
/// referral status loads. Mirrors the summary card + how-it-works layout.
class ReferralStatusSkeleton extends StatelessWidget {
  const ReferralStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 240.h, borderRadius: BorderRadius.circular(28.r)),
            SizedBox(height: 18.h),
            SkeletonBox(height: 140.h, borderRadius: BorderRadius.circular(24.r)),
          ],
        ),
      ),
    );
  }
}
