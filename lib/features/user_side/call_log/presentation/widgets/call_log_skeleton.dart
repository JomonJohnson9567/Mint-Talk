import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [CallLogContents] while call logs
/// load. Mirrors [CallLogItem]'s avatar + name + time layout.
class CallLogSkeleton extends StatelessWidget {
  const CallLogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 10),
        itemCount: 8,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFE7EBF3)),
          ),
          child: Row(
            children: [
              SkeletonBox(width: 50.w, height: 50.w, shape: BoxShape.circle),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 130.w, height: 15.h),
                    SizedBox(height: 8.h),
                    SkeletonBox(width: 90.w, height: 11.h),
                  ],
                ),
              ),
              SkeletonBox(width: 24.w, height: 24.w, shape: BoxShape.circle),
            ],
          ),
        ),
      ),
    );
  }
}
