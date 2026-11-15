import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [UserRechargeHistoryContents] while
/// history loads. Mirrors the summary card, section title and item cards.
class UserRechargeHistorySkeleton extends StatelessWidget {
  const UserRechargeHistorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.cw, 4.cw, 16.cw, 24.cw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(
              height: 118.cw,
              borderRadius: BorderRadius.circular(18.cw),
            ),
            SizedBox(height: 22.cw),
            Align(
              alignment: Alignment.centerLeft,
              child: SkeletonBox(
                width: 130.cw,
                height: 18.cw,
                borderRadius: BorderRadius.circular(6.cw),
              ),
            ),
            SizedBox(height: 12.cw),
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.cw),
                child: SkeletonBox(
                  height: 112.cw,
                  borderRadius: BorderRadius.circular(18.cw),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
