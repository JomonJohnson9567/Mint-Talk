import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [HostProfileScreen]. Mirrors its header,
/// hero card, rate tiles, account details card and log out tile.
class HostProfileSkeleton extends StatelessWidget {
  const HostProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
        child: Center(
          // Same tablet width cap as HostProfileScreen.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SkeletonBox(
                      width: 40.cw,
                      height: 40.cw,
                      shape: BoxShape.circle,
                    ),
                    SizedBox(width: 14.cw),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 150.cw, height: 26.cw),
                        SizedBox(height: 6.cw),
                        SkeletonBox(width: 180.cw, height: 12.cw),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18.cw),
                _card(
                  color: AppColors.hostPromoBanner,
                  padding: EdgeInsets.all(18.cw),
                  child: Row(
                    children: [
                      SkeletonBox(
                        width: 82.cw,
                        height: 82.cw,
                        shape: BoxShape.circle,
                      ),
                      SizedBox(width: 14.cw),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 120.cw, height: 18.cw),
                            SizedBox(height: 8.cw),
                            SkeletonBox(
                              width: 90.cw,
                              height: 18.cw,
                              borderRadius: BorderRadius.circular(12.cw),
                            ),
                            SizedBox(height: 8.cw),
                            SkeletonBox(width: 100.cw, height: 12.cw),
                            SizedBox(height: 12.cw),
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
                ),
                SizedBox(height: 22.cw),
                SkeletonBox(width: 110.cw, height: 18.cw),
                SizedBox(height: 10.cw),
                Row(
                  children: [
                    for (var i = 0; i < 2; i++) ...[
                      if (i == 1) SizedBox(width: 10.cw),
                      Expanded(
                        child: _card(
                          padding: EdgeInsets.all(14.cw),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SkeletonBox(
                                width: 40.cw,
                                height: 40.cw,
                                borderRadius: BorderRadius.circular(12.cw),
                              ),
                              SizedBox(height: 12.cw),
                              SkeletonBox(width: 70.cw, height: 12.cw),
                              SizedBox(height: 6.cw),
                              SkeletonBox(width: 90.cw, height: 20.cw),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 22.cw),
                SkeletonBox(width: 140.cw, height: 18.cw),
                SizedBox(height: 10.cw),
                _card(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.cw,
                    vertical: 4.cw,
                  ),
                  child: Column(
                    children: List.generate(
                      5,
                      (_) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 11.cw),
                        child: Row(
                          children: [
                            SkeletonBox(
                              width: 40.cw,
                              height: 40.cw,
                              borderRadius: BorderRadius.circular(12.cw),
                            ),
                            SizedBox(width: 14.cw),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBox(width: 70.cw, height: 10.cw),
                                SizedBox(height: 6.cw),
                                SkeletonBox(width: 130.cw, height: 14.cw),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18.cw),
                SkeletonBox(
                  width: double.infinity,
                  height: 68.cw,
                  borderRadius: BorderRadius.circular(18.cw),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required EdgeInsets padding,
    required Widget child,
    Color color = AppColors.cardWhite,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: child,
    );
  }
}
