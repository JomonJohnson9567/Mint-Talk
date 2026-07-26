import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Grid of shimmer cards shown while the socket is connecting and no
/// host_status_update events have arrived yet.
///
/// Mirrors the exact layout of [UserGrid] / [UserGridItem] so there is no
/// visual jump when real data populates.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 3;
        if (constraints.maxWidth >= 1200) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 900) {
          crossAxisCount = 5;
        } else if (constraints.maxWidth >= 600) {
          crossAxisCount = 4;
        }

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 10.h,
            bottom: 110.h,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 15.h,
            mainAxisExtent: 190.h,
          ),
          itemCount: 9,
          itemBuilder: (context, index) => const _SkeletonCard(),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // Avatar circle
              SkeletonBox(
                width: 64.w,
                height: 64.w,
                shape: BoxShape.circle,
              ),
              SizedBox(height: 10.h),
              // Name
              SkeletonBox(
                width: 60.w,
                height: 10.h,
                borderRadius: BorderRadius.circular(6.r),
              ),
              SizedBox(height: 6.h),
              // Status dot + label row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(
                    width: 6.w,
                    height: 6.w,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 4.w),
                  SkeletonBox(
                    width: 32.w,
                    height: 8.h,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ],
              ),
            ],
          ),
          // Button
          SkeletonBox(
            width: double.infinity,
            height: 32.h,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
    );
  }
}
