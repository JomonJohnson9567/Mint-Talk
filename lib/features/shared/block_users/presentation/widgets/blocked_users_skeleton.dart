import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [BlockedUsersContents] while the blocked
/// list loads. Mirrors [BlockedUserTile]'s avatar + two lines + pill layout.
class BlockedUsersSkeleton extends StatelessWidget {
  const BlockedUsersSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          for (var i = 0; i < 6; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.cw),
              child: Row(
                children: [
                  SkeletonBox(
                    width: 56.cw,
                    height: 56.cw,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 14.cw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120.cw, height: 15.cw),
                        SizedBox(height: 8.cw),
                        SkeletonBox(width: 90.cw, height: 12.cw),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.cw),
                  SkeletonBox(
                    width: 88.cw,
                    height: 36.cw,
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
