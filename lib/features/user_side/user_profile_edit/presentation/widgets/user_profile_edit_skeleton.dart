import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

/// Skeleton loading placeholder for [UserProfileEdit] while the profile
/// loads. Mirrors [UserProfileEditContents]'s header, hero card, section
/// cards and sticky save bar.
class UserProfileEditSkeleton extends StatelessWidget {
  const UserProfileEditSkeleton({super.key});

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
                    padding: EdgeInsets.all(18.cw),
                    child: Row(
                      children: [
                        SkeletonBox(
                          width: 82.cw,
                          height: 82.cw,
                          shape: BoxShape.circle,
                        ),
                        SizedBox(width: 12.cw),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 120.cw, height: 18.cw),
                            SizedBox(height: 12.cw),
                            SkeletonBox(
                              width: 120.cw,
                              height: 28.cw,
                              borderRadius: BorderRadius.circular(20.cw),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.cw),
                  SkeletonBox(width: 140.cw, height: 18.cw),
                  SizedBox(height: 10.cw),
                  _card(
                    padding: EdgeInsets.all(16.cw),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 80.cw, height: 12.cw),
                        SizedBox(height: 8.cw),
                        SkeletonBox(
                          width: double.infinity,
                          height: 52.cw,
                          borderRadius: BorderRadius.circular(16.cw),
                        ),
                      ],
                    ),
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
                        3,
                        (_) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 11.cw),
                          child: Row(
                            children: [
                              SkeletonBox(
                                width: 36.cw,
                                height: 36.cw,
                                shape: BoxShape.circle,
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
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 12.cw),
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

  Widget _card({required EdgeInsets padding, required Widget child}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: child,
    );
  }
}
