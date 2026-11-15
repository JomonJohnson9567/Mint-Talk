import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [NotificationsListBody] while the first
/// page loads. Mirrors [NotificationTile]'s icon + two lines + time layout.
class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.cw),
          SkeletonBox(width: 80.cw, height: 18.cw),
          for (var i = 0; i < 7; i++)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.cw),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(
                    width: 46.cw,
                    height: 46.cw,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 14.cw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 140.cw, height: 15.cw),
                        SizedBox(height: 8.cw),
                        SkeletonBox(width: double.infinity, height: 12.cw),
                        SizedBox(height: 6.cw),
                        SkeletonBox(width: 120.cw, height: 12.cw),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.cw),
                  SkeletonBox(width: 40.cw, height: 12.cw),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
