import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import '../cubit/host_dash_cubit.dart';
import 'host_dash_motion.dart';
import '../cubit/host_dash_state.dart';
import '../../domain/entities/host_online_item_entity.dart';

/// "Hosts online" summary. By default a compact strip (live count on the
/// left, overlapping avatars on the right); with [stacked] the count sits on
/// top and the avatars run underneath — the layout used while waiting for a
/// call.
class HostsOnlineGrid extends StatelessWidget {
  final bool stacked;

  const HostsOnlineGrid({super.key, this.stacked = false});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      HostDashCubit,
      HostDashState,
      List<HostOnlineItemEntity>
    >(
      selector: (state) => state.onlineHosts,
      builder: (context, hosts) {
        final onlineCount = hosts
            .where((h) => h.status == UserStatus.online)
            .length;
        final displayCount = onlineCount > 0 ? onlineCount : hosts.length;
        final shown = hosts.take(stacked ? 5 : 4).toList();
        final overflow = hosts.length - shown.length;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.cw,
              vertical: stacked ? 14.cw : 12.cw,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.profileDivider, width: 1.cw),
            ),
            child: HostDashSwitcher(
              child: KeyedSubtree(
                key: ValueKey(stacked),
                child: stacked
                    ? _buildStacked(displayCount, shown, overflow)
                    : _buildStrip(displayCount, shown, overflow),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStrip(
    int displayCount,
    List<HostOnlineItemEntity> shown,
    int overflow,
  ) {
    return Row(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.hostsOnline,
              style: TextStyle(
                fontSize: 11.csp,
                fontWeight: FontWeight.w500,
                color: AppColors.hostSubtitle,
              ),
            ),
            SizedBox(height: 4.cw),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9.cw,
                  height: 9.cw,
                  decoration: const BoxDecoration(
                    color: AppColors.onlineIndicator,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.cw),
                Text(
                  '$displayCount ${AppTexts.online.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 17.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 14.cw),
          width: 1.cw,
          height: 34.cw,
          color: AppColors.profileDivider,
        ),
        Expanded(
          // Scales the stack down instead of overflowing on narrow phones.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: _AvatarStack(hosts: shown, overflow: overflow, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildStacked(
    int displayCount,
    List<HostOnlineItemEntity> shown,
    int overflow,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppTexts.hostsOnline,
                style: TextStyle(
                  fontSize: 15.csp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plumDeep,
                ),
              ),
            ),
            Text(
              '$displayCount',
              style: TextStyle(
                fontSize: 16.csp,
                fontWeight: FontWeight.w700,
                color: AppColors.plumDeep,
              ),
            ),
          ],
        ),
        if (shown.isNotEmpty) ...[
          SizedBox(height: 10.cw),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _AvatarStack(hosts: shown, overflow: overflow, size: 40),
          ),
        ],
      ],
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<HostOnlineItemEntity> hosts;
  final int overflow;
  final double size;

  const _AvatarStack({
    required this.hosts,
    required this.overflow,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final double size = this.size.cw;
    final double step = size * 0.78;
    final int count = hosts.length + (overflow > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    return SizedBox(
      width: size + step * (count - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < hosts.length; i++)
            Positioned(
              left: step * i,
              child: _AvatarCircle(
                size: size,
                child: _buildHostImage(hosts[i].imageUrl),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: step * hosts.length,
              child: _AvatarCircle(
                size: size,
                color: AppColors.pillUnselected,
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      fontSize: 12.csp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.hostSubtitle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHostImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => _buildFallbackAsset(),
        placeholder: (context, url) => Container(color: AppColors.lightGrey),
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAsset(),
      );
    }
    return _buildFallbackAsset();
  }

  Widget _buildFallbackAsset() {
    return Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover);
  }
}

class _AvatarCircle extends StatelessWidget {
  final double size;
  final Widget child;
  final Color color;

  const _AvatarCircle({
    required this.size,
    required this.child,
    this.color = AppColors.hostAvatarBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2.cw),
      ),
      child: ClipOval(child: child),
    );
  }
}
