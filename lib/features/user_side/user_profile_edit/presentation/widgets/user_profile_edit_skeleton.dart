import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [UserProfileEdit] while the profile
/// loads. Mirrors [UserProfileEditContents]'s avatar + form card layout.
class UserProfileEditSkeleton extends StatelessWidget {
  const UserProfileEditSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 36.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SkeletonBox(
                width: 88.w,
                height: 88.w,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFFE7EBF3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 150.w, height: 18.h),
                  SizedBox(height: 8.h),
                  SkeletonBox(width: 220.w, height: 12.h),
                  SizedBox(height: 24.h),
                  ...List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 18.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 90.w, height: 12.h),
                          SizedBox(height: 8.h),
                          SkeletonBox(
                            width: double.infinity,
                            height: 48.h,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SkeletonBox(
              width: double.infinity,
              height: 52.h,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ],
        ),
      ),
    );
  }
}
