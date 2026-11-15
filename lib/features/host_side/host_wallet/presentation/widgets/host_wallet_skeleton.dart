import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Mirrors the wallet layout: hero banner, balance card, three summary tiles
/// and the recent withdrawals list.
class HostWalletSkeleton extends StatelessWidget {
  const HostWalletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tileRadius = BorderRadius.circular(16.r);

    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.cw, 4.cw, 16.cw, 24.cw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(
              height: 120.cw,
              borderRadius: BorderRadius.circular(20.r),
            ),
            SizedBox(height: 14.cw),
            SkeletonBox(
              height: 140.cw,
              borderRadius: BorderRadius.circular(22.r),
            ),
            SizedBox(height: 14.cw),
            Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) SizedBox(width: 10.cw),
                  Expanded(
                    child: SkeletonBox(
                      height: 104.cw,
                      borderRadius: tileRadius,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 22.cw),
            SkeletonBox(width: 170.cw, height: 18.cw),
            SizedBox(height: 12.cw),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 10.cw),
                child: SkeletonBox(
                  height: 66.cw,
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
