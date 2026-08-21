import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import '../cubit/host_dash_cubit.dart';
import '../cubit/host_dash_state.dart';
import '../../domain/entities/host_online_item_entity.dart';

class HostsOnlineGrid extends StatelessWidget {
  const HostsOnlineGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostDashCubit, HostDashState>(
      builder: (context, state) {
        final hosts = state.onlineHosts;
        final onlineCount = hosts
            .where((h) => h.status == UserStatus.online)
            .length;
        final displayCount = onlineCount > 0 ? onlineCount : hosts.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    'Hosts Online',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Green Status Dot
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFF18A957),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '$displayCount Online',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF18A957),
                    ),
                  ),
                ],
              ),
            ),
            // Hosts Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hosts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final host = hosts[index];
                  return HostGridItemCard(host: host);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class HostGridItemCard extends StatelessWidget {
  final HostOnlineItemEntity host;

  const HostGridItemCard({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    final bool isOnline = host.status == UserStatus.online;
    final Color statusColor =
        isOnline ? const Color(0xFF18A957) : const Color(0xFFFFB800);
    final String statusText = isOnline ? 'Online' : 'On Call';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE7EBF3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image with online / on-call status dot
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(11.r),
                    ),
                    child: _buildHostImage(host.imageUrl),
                  ),
                ),
                // Status indicator dot at top-right
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 1.5.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Host Details at bottom of card
          Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  host.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                // Status Text Row (replacing star rating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
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
        placeholder: (context, url) {
          return Container(
            color: AppColors.lightGrey,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          );
        },
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
    return Image.asset(
      'assets/images/profile setup/female.jpg',
      fit: BoxFit.cover,
    );
  }
}
