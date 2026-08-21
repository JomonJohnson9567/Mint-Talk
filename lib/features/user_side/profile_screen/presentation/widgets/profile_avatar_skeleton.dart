import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for the avatar + name + phone block in
/// [ProfileAvatar] while [ProfileInfoCubit] loads.
class ProfileAvatarSkeleton extends StatelessWidget {
  const ProfileAvatarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          SkeletonBox(width: 108.r, height: 108.r, shape: BoxShape.circle),
          SizedBox(height: 16.h),
          SkeletonBox(width: 140.w, height: 20.h),
          SizedBox(height: 8.h),
          SkeletonBox(width: 110.w, height: 14.h),
        ],
      ),
    );
  }
}
