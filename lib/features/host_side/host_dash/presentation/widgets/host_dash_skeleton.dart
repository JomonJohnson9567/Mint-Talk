import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';

class HostDashSkeleton extends StatelessWidget {
  const HostDashSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 14.cw,
          ).copyWith(top: 8.cw, bottom: 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: wordmark + two minutes chips
              Row(
                children: [
                  SkeletonBox(width: 130.cw, height: 30.cw),
                  const Spacer(),
                  SkeletonBox(
                    width: 74.cw,
                    height: 38.cw,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  SizedBox(width: 6.cw),
                  SkeletonBox(
                    width: 74.cw,
                    height: 38.cw,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ],
              ),
              SizedBox(height: 14.cw),

              // Profile row
              Row(
                children: [
                  SkeletonBox(
                    width: 68.cw,
                    height: 68.cw,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 12.cw),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 110.cw, height: 16.cw),
                      SizedBox(height: 8.cw),
                      SkeletonBox(width: 80.cw, height: 12.cw),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.cw),

              // Greeting banner
              SkeletonBox(
                width: double.infinity,
                height: 120.cw,
                borderRadius: BorderRadius.circular(22.r),
              ),
              SizedBox(height: 10.cw),

              // Ready to connect card
              Container(
                padding: EdgeInsets.all(14.cw),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: AppColors.profileDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 170.cw, height: 18.cw),
                    SizedBox(height: 8.cw),
                    SkeletonBox(width: 190.cw, height: 12.cw),
                    SizedBox(height: 14.cw),
                    Row(
                      children: [
                        Expanded(
                          child: SkeletonBox(
                            height: 110.cw,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                        SizedBox(width: 10.cw),
                        Expanded(
                          child: SkeletonBox(
                            height: 110.cw,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.cw),
                    SkeletonBox(
                      width: double.infinity,
                      height: 52.cw,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.cw),

              // Hosts online strip
              SkeletonBox(
                width: double.infinity,
                height: 66.cw,
                borderRadius: BorderRadius.circular(18.r),
              ),
              SizedBox(height: 10.cw),

              // Promo banner
              SkeletonBox(
                width: double.infinity,
                height: 104.cw,
                borderRadius: BorderRadius.circular(22.r),
              ),
              SizedBox(height: 10.cw),

              // Refer a host banner
              SkeletonBox(
                width: double.infinity,
                height: 70.cw,
                borderRadius: BorderRadius.circular(18.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
