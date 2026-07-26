import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

class HostCallLogSkeleton extends StatelessWidget {
  const HostCallLogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: SkeletonBox(
            width: double.infinity,
            height: 44.h,
            borderRadius: BorderRadius.circular(22.r),
          ),
        ),
        // Filter tabs skeleton
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: SkeletonBox(
                  height: 38.h,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: SkeletonBox(
                  height: 38.h,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        // Call log items list skeleton
        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
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
                        width: 48.r,
                        height: 48.r,
                        shape: BoxShape.circle,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 110.w, height: 16.h),
                            SizedBox(height: 6.h),
                            SkeletonBox(width: 70.w, height: 12.h),
                          ],
                        ),
                      ),
                      SkeletonBox(
                        width: 36.w,
                        height: 36.h,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
