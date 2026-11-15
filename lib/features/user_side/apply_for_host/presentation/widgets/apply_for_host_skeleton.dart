import 'package:flutter/material.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for the [ApplyForHost] screen while profile data loads.
class ApplyForHostSkeleton extends StatelessWidget {
  const ApplyForHostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SkeletonBox(
                        width: 40.cw,
                        height: 40.cw,
                        borderRadius: BorderRadius.circular(20.cw),
                      ),
                      SizedBox(width: 14.cw),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            width: 180.cw,
                            height: 26.cw,
                            borderRadius: BorderRadius.circular(6.cw),
                          ),
                          SizedBox(height: 6.cw),
                          SkeletonBox(
                            width: 150.cw,
                            height: 12.cw,
                            borderRadius: BorderRadius.circular(4.cw),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 18.cw),
                  SkeletonBox(
                    width: double.infinity,
                    height: 150.cw,
                    borderRadius: BorderRadius.circular(20.cw),
                  ),
                  SizedBox(height: 22.cw),
                  const _SectionSkeleton(cardHeight: 330),
                  SizedBox(height: 22.cw),
                  const _SectionSkeleton(cardHeight: 142),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 12.cw),
            child: SafeArea(
              top: false,
              child: SkeletonBox(
                width: double.infinity,
                height: 52.cw,
                borderRadius: BorderRadius.circular(30.cw),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.cardHeight});

  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonBox(
          width: 140.cw,
          height: 18.cw,
          borderRadius: BorderRadius.circular(4.cw),
        ),
        SizedBox(height: 10.cw),
        SkeletonBox(
          width: double.infinity,
          height: cardHeight.cw,
          borderRadius: BorderRadius.circular(18.cw),
        ),
      ],
    );
  }
}
