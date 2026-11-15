import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [HostAnalytics] while the earnings
/// ledger loads. Mirrors the banner + stat tiles + ledger list layout.
class HostAnalyticsSkeleton extends StatelessWidget {
  const HostAnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tileRadius = BorderRadius.circular(18.r);

    Widget tileRow() => Row(
      children: [
        Expanded(
          child: SkeletonBox(height: 78.cw, borderRadius: tileRadius),
        ),
        SizedBox(width: 12.cw),
        Expanded(
          child: SkeletonBox(height: 78.cw, borderRadius: tileRadius),
        ),
      ],
    );

    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.cw, 4.cw, 16.cw, 24.cw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(
              height: 110.cw,
              borderRadius: BorderRadius.circular(20.r),
            ),
            SizedBox(height: 16.cw),
            tileRow(),
            SizedBox(height: 12.cw),
            tileRow(),
            SizedBox(height: 22.cw),
            SkeletonBox(width: 150.cw, height: 18.cw),
            SizedBox(height: 12.cw),
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 12.cw),
                child: SkeletonBox(
                  height: 64.cw,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
