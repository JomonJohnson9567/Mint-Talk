import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/host_card_actions.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';

/// List-layout counterpart of [UserGridItem]: photo, name and status on the
/// left, favorite + call/notify on the right, in one compact row.
class UserListTile extends StatelessWidget with HostCardActions {
  @override
  final HostEntity host;

  @override
  final CallType? callType;

  final bool bare;

  const UserListTile({
    super.key,
    required this.host,
    this.callType,
    this.bare = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hostTileExtent(),
      padding: EdgeInsets.all(kHostTilePadding.cw),
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
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openProfile(context),
            child: _buildAvatar(),
          ),
          SizedBox(width: 10.cw),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => openProfile(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.csp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.plumDeep,
                    ),
                  ),
                  SizedBox(height: 3.cw),
                  Text(
                    statusLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.csp,
                      fontWeight: FontWeight.w600,
                      color: isOnline
                          ? AppColors.onlineIndicator
                          : AppColors.subtitleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          HostFavoriteButton(hostId: host.id),
          SizedBox(width: 8.cw),
          SizedBox(width: 84.cw, child: buildCallAction(context)),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final size = kHostTileAvatar.cw;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (!bare)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: buildPhoto(),
            ),
          Positioned(
            right: 3.cw,
            bottom: 3.cw,
            child: Container(
              width: 11.cw,
              height: 11.cw,
              decoration: BoxDecoration(
                color: statusColor(),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2.cw),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
