import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [UserRechargeHistoryContents] while
/// history loads. Mirrors the summary card + item card layout.
class UserRechargeHistorySkeleton extends StatelessWidget {
  const UserRechargeHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 190.h, borderRadius: BorderRadius.circular(28.r)),
            SizedBox(height: 18.h),
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: SkeletonBox(
                  height: 130.h,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
