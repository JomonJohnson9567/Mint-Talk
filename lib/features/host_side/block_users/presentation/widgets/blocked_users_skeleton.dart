import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [BlockedUsersContents] while the
/// blocked list loads. Mirrors [BlockedUserTile]'s avatar + info layout.
class BlockedUsersSkeleton extends StatelessWidget {
  const BlockedUsersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE7EBF3)),
          ),
          child: Row(
            children: [
              SkeletonBox(width: 52.w, height: 52.w, shape: BoxShape.circle),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120.w, height: 14.h),
                    SizedBox(height: 8.h),
                    SkeletonBox(width: 180.w, height: 12.h),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              SkeletonBox(
                width: 40.w,
                height: 40.w,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
