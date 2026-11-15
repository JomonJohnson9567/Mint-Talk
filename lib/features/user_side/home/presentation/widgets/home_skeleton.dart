import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/skeleton_loader.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_state.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';

/// Grid of shimmer cards shown while the socket is connecting and no
/// host_status_update events have arrived yet.
///
/// Mirrors the exact layout of [UserGrid] / [UserGridItem] so there is no
/// visual jump when real data populates. Shrink-wrapped because it sits
/// inside [UserGrid]'s scroll view.
class HomeSkeleton extends StatelessWidget {
  final HostLayout layout;

  const HomeSkeleton({super.key, this.layout = HostLayout.grid});

  @override
  Widget build(BuildContext context) {
    if (layout == HostLayout.list) {
      return SkeletonShimmer(
        child: LayoutBuilder(
          builder: (context, constraints) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 14.cw,
              right: 14.cw,
              top: 4.cw,
              bottom: 95.cw,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: hostListCrossAxisCount(constraints.maxWidth),
              crossAxisSpacing: 8.cw,
              mainAxisSpacing: 8.cw,
              mainAxisExtent: hostTileExtent(),
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const _SkeletonTile(),
          ),
        ),
      );
    }

    return SkeletonShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = hostGridCrossAxisCount(constraints.maxWidth);
          final spacing = 8.cw;
          final horizontalPadding = 14.cw;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: 4.cw,
              bottom: 95.cw,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: 10.cw,
              mainAxisExtent: hostCardExtent(
                hostCardWidth(
                  constraints.maxWidth - horizontalPadding * 2,
                  crossAxisCount,
                  spacing,
                ),
              ),
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const _SkeletonCard(),
          );
        },
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          AspectRatio(
            aspectRatio: kHostPhotoAspectRatio,
            child: SkeletonBox(width: double.infinity),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.cw, 8.cw, 8.cw, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                SkeletonBox(
                  width: 60.cw,
                  height: 10.cw,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                SizedBox(height: 6.cw),
                // Status label
                SkeletonBox(
                  width: 36.cw,
                  height: 8.cw,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Call buttons
          Padding(
            padding: EdgeInsets.only(bottom: 8.cw),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SkeletonBox(
                  width: 32.cw,
                  height: 32.cw,
                  shape: BoxShape.circle,
                ),
                SkeletonBox(
                  width: 32.cw,
                  height: 32.cw,
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

/// Mirrors [UserListTile]: avatar, name + status, then the call pill.
class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hostTileExtent(),
      padding: EdgeInsets.all(kHostTilePadding.cw),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          SkeletonBox(
            width: kHostTileAvatar.cw,
            height: kHostTileAvatar.cw,
            borderRadius: BorderRadius.circular(12.r),
          ),
          SizedBox(width: 10.cw),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: 110.cw,
                  height: 11.cw,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                SizedBox(height: 7.cw),
                SkeletonBox(
                  width: 48.cw,
                  height: 8.cw,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ],
            ),
          ),
          SkeletonBox(
            width: 84.cw,
            height: 30.cw,
            borderRadius: BorderRadius.circular(18.r),
          ),
        ],
      ),
    );
  }
}
