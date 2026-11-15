import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for the avatar + name + edit button row in
/// [ProfileHeaderCard] while [ProfileInfoCubit] loads.
class ProfileAvatarSkeleton extends StatelessWidget {
  const ProfileAvatarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Row(
        children: [
          SkeletonBox(width: 82.cw, height: 82.cw, shape: BoxShape.circle),
          SizedBox(width: 12.cw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120.cw, height: 18.cw),
                SizedBox(height: 8.cw),
                SkeletonBox(width: double.infinity, height: 12.cw),
                SizedBox(height: 4.cw),
                SkeletonBox(width: 90.cw, height: 12.cw),
                SizedBox(height: 10.cw),
                SkeletonBox(
                  width: 110.cw,
                  height: 28.cw,
                  borderRadius: BorderRadius.circular(20.cw),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
