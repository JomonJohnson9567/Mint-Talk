import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for the [HostApplicationStatus] screen.
class HostApplicationStatusSkeleton extends StatelessWidget {
  const HostApplicationStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
      children: [
        const _StatusCardSkeleton(),
        SizedBox(height: 20.h),
        const _DetailsCardSkeleton(),
        SizedBox(height: 20.h),
        const _ReviewNoteSkeleton(),
      ],
    );
  }
}

class _StatusCardSkeleton extends StatelessWidget {
  const _StatusCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          SkeletonBox(
            width: 76.w,
            height: 76.w,
            shape: BoxShape.circle,
          ),
          SizedBox(height: 18.h),
          SkeletonBox(
            width: 180.w,
            height: 22.h,
            borderRadius: BorderRadius.circular(6.r),
          ),
          SizedBox(height: 12.h),
          SkeletonBox(
            width: 240.w,
            height: 14.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 6.h),
          SkeletonBox(
            width: 160.w,
            height: 14.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}

class _DetailsCardSkeleton extends StatelessWidget {
  const _DetailsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 150.w,
            height: 18.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
          SizedBox(height: 20.h),
          const _DetailRowSkeleton(labelWidth: 100, valueWidth: 110),
          Divider(height: 28.h, color: AppColors.borderSoft),
          const _DetailRowSkeleton(labelWidth: 80, valueWidth: 90),
          SizedBox(height: 14.h),
          const _DetailRowSkeleton(labelWidth: 120, valueWidth: 130),
          SizedBox(height: 14.h),
          const _DetailRowSkeleton(labelWidth: 90, valueWidth: 80),
        ],
      ),
    );
  }
}

class _DetailRowSkeleton extends StatelessWidget {
  final double labelWidth;
  final double valueWidth;

  const _DetailRowSkeleton({
    required this.labelWidth,
    required this.valueWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonBox(
          width: labelWidth.w,
          height: 14.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
        SkeletonBox(
          width: valueWidth.w,
          height: 14.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
    );
  }
}

class _ReviewNoteSkeleton extends StatelessWidget {
  const _ReviewNoteSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(
          width: 20.w,
          height: 20.w,
          shape: BoxShape.circle,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SkeletonBox(
            height: 14.h,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }
}
