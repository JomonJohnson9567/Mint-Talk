import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [CallLogContents] while call logs
/// load. Mirrors [CallLogItem]'s avatar + two lines + call button layout.
class CallLogSkeleton extends StatelessWidget {
  const CallLogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.cw),
          SkeletonBox(width: 80.cw, height: 18.cw),
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
                        SkeletonBox(width: 110.cw, height: 15.cw),
                        SizedBox(height: 8.cw),
                        SkeletonBox(width: 80.cw, height: 12.cw),
                      ],
                    ),
                  ),
                  SkeletonBox(width: 56.cw, height: 12.cw),
                  SizedBox(width: 12.cw),
                  SkeletonBox(
                    width: 46.cw,
                    height: 46.cw,
                    shape: BoxShape.circle,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
