import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

class HostSettingsSkeleton extends StatelessWidget {
  const HostSettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      itemCount: 7,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE7EBF3)),
            ),
            child: Row(
              children: [
                SkeletonBox(
                  width: 44.r,
                  height: 44.r,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 120.w, height: 16.h),
                      SizedBox(height: 6.h),
                      SkeletonBox(width: 180.w, height: 12.h),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                SkeletonBox(
                  width: 16.w,
                  height: 16.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
