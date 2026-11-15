import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/host_card_actions.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';

class UserGridItem extends StatelessWidget with HostCardActions {
  @override
  final HostEntity host;

  /// When set, an online host gets one full-width call button of this type
  /// instead of the video + audio circle buttons.
  @override
  final CallType? callType;

  /// Layer mode for [HostLayoutMorphSliver]: no card background and an empty
  /// (still tappable) photo slot — the morph draws both itself so the photo
  /// can fly between layouts.
  final bool bare;

  const UserGridItem({
    super.key,
    required this.host,
    this.callType,
    this.bare = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: bare
          ? null
          : BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      clipBehavior: bare ? Clip.none : Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: kHostPhotoAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openProfile(context),
                  child: bare ? const SizedBox.expand() : buildPhoto(),
                ),
                Positioned(
                  top: 6.cw,
                  right: 6.cw,
                  child: HostFavoriteButton(hostId: host.id),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.cw, 7.cw, 6.cw, 0),
            child: Row(
              children: [
                Container(
                  width: 7.cw,
                  height: 7.cw,
                  decoration: BoxDecoration(
                    color: statusColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.cw),
                Expanded(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.csp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.plumDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.cw, top: 1.cw),
            child: Text(
              statusLabel(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.csp,
                fontWeight: FontWeight.w500,
                color: AppColors.subtitleText,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(6.cw, 0, 6.cw, 8.cw),
            child: buildCallAction(context),
          ),
        ],
      ),
    );
  }
}
