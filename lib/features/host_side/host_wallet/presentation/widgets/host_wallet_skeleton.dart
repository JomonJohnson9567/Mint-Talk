import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

class HostWalletSkeleton extends StatelessWidget {
  const HostWalletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          // Hero section skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                SkeletonBox(
                  width: 52.w,
                  height: 52.w,
                  shape: BoxShape.circle,
                ),
                SizedBox(width: 14.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120.w, height: 16.h),
                    SizedBox(height: 6.h),
                    SkeletonBox(width: 180.w, height: 12.h),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Balance card skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SkeletonBox(
              width: double.infinity,
              height: 140.h,
              borderRadius: BorderRadius.circular(22.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Summary row skeleton (Row of 3 cards)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 10.w),
                    child: SkeletonBox(
                      height: 84.h,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // History section header skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 130.w, height: 18.h),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // History list skeleton (List of 3 items)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE7EBF3)),
                  ),
                  child: Row(
                    children: [
                      SkeletonBox(
                        width: 42.w,
                        height: 42.w,
                        shape: BoxShape.circle,
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 100.w, height: 14.h),
                            SizedBox(height: 6.h),
                            SkeletonBox(width: 70.w, height: 11.h),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SkeletonBox(width: 60.w, height: 14.h),
                          SizedBox(height: 6.h),
                          SkeletonBox(width: 45.w, height: 11.h),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}
