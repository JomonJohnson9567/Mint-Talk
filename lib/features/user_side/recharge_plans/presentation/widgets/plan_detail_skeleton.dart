import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [PlanDetailScreen] while a plan is
/// fetched by id. Mirrors the hero + "What you get" + summary layout.
class PlanDetailSkeleton extends StatelessWidget {
  const PlanDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.cw, 8.cw, 16.cw, 24.cw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(
              height: 250.cw,
              borderRadius: BorderRadius.circular(24.cw),
            ),
            SizedBox(height: 22.cw),
            SkeletonBox(width: 130.cw, height: 18.cw),
            SizedBox(height: 12.cw),
            SkeletonBox(
              height: 190.cw,
              borderRadius: BorderRadius.circular(18.cw),
            ),
            SizedBox(height: 22.cw),
            SkeletonBox(width: 150.cw, height: 18.cw),
            SizedBox(height: 12.cw),
            SkeletonBox(
              height: 180.cw,
              borderRadius: BorderRadius.circular(18.cw),
            ),
          ],
        ),
      ),
    );
  }
}
