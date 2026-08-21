// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/call_type_selection_bottom_sheet.dart';

class UserGridItem extends StatelessWidget {
  final HostEntity host;

  const UserGridItem({super.key, required this.host});

  // ── Derived presence helpers ─────────────────────────────────────────────

  bool get _isOnline =>
      host.presence?.status == 'online' &&
      host.presence?.busy != true &&
      host.presence?.state != 'busy';
  bool get _isBusy =>
      host.presence?.busy == true || host.presence?.state == 'busy';
  bool get _isOffline => !_isOnline && !_isBusy;

  // Maps presence state → the colour used for the status dot and border ring
  Color _statusColor() {
    if (_isOnline) return AppColors.green;
    if (_isBusy) return AppColors.termsIcon;
    return AppColors.favIcon;
  }

  String _statusLabel() {
    if (_isOnline) return AppTexts.online;
    if (_isBusy) return AppTexts.onCall;
    return AppTexts.offline;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildCard(context),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: _FavoriteButton(hostId: host.id),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar with online ring
                GestureDetector(
                  onTap: () {
                    // `host.isFavorite` is never populated by `HomeCubit`
                    // (favorite status lives separately in
                    // `HomeState.favoriteIds`, sourced from the backend
                    // favorites list) — stamp the real value on before
                    // handing the entity to the profile screen, or its
                    // favorite icon starts stale/unfavorited regardless of
                    // what's shown here on the grid.
                    final isFavorite = context
                        .read<HomeCubit>()
                        .state
                        .favoriteIds
                        .contains(host.id);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.hostProfileScreen,
                      arguments: host.copyWith(isFavorite: isFavorite),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isOnline
                            ? AppColors.green
                            : AppColors.transparent,
                        width: 2.w,
                      ),
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: ClipOval(
                      child: host.avatarUrl.isNotEmpty
                          ? (host.avatarUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: host.avatarUrl,
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      _buildPlaceholderAvatar(60.w),
                                )
                              : Image.asset(
                                  host.avatarUrl,
                                  width: 60.w,
                                  height: 60.w,
                                  fit: BoxFit.cover,
                                ))
                          : _buildPlaceholderAvatar(60.w),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // Name
                Text(
                  host.fullName.isNotEmpty
                      ? host.fullName
                      : (host.id.isNotEmpty
                          ? 'Host (${host.id.length > 6 ? host.id.substring(0, 6) : host.id})'
                          : 'Host'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                // Status dot + label
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: _statusColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _statusLabel(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: _statusColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          // CTA button
          SizedBox(
            width: double.infinity,
            height: 32.h,
            child: ElevatedButton(
              onPressed: () {
                if (!_isOnline) {
                  context.read<HomeCubit>().notifyUser(host);
                  return;
                }

                final isAudioAvailable = host.presence?.audioAvailable ?? true;
                final isVideoAvailable = host.presence?.videoAvailable ?? true;

                if (isAudioAvailable && isVideoAvailable) {
                  CallTypeSelectionBottomSheet.show(context, host);
                } else if (isVideoAvailable) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        hostId: host.id,
                        hostName: host.fullName,
                        hostAvatar: host.avatarUrl,
                        callType: CallType.video,
                      ),
                    ),
                  );
                } else if (isAudioAvailable) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        hostId: host.id,
                        hostName: host.fullName,
                        hostAvatar: host.avatarUrl,
                        callType: CallType.audio,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${host.fullName} is currently not accepting calls.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor:
                    _isOnline ? AppColors.primaryColor : AppColors.white,
                foregroundColor:
                    _isOnline ? AppColors.white : AppColors.primaryColor,
                side: _isOffline || _isBusy
                    ? BorderSide(color: AppColors.primaryColor, width: 1.w)
                    : null,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                _isOnline ? AppTexts.callNow : AppTexts.notifyMe,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar([double? size]) {
    return Container(
      width: size ?? 70.w,
      height: size ?? 70.h,
      color: AppColors.lightGrey,
      child: Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final String hostId;

  const _FavoriteButton({required this.hostId});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<HomeCubit, bool>(
      (cubit) => cubit.state.favoriteIds.contains(hostId),
    );

    return GestureDetector(
      onTap: () => context.read<HomeCubit>().toggleFavorite(hostId),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: isFavorite ? 400 : 200),
          transitionBuilder: (child, animation) {
            // Favoriting gets a bouncy pop-in; unfavoriting just fades —
            // the pop is the "you just added this" feedback, so it only
            // belongs on the way in.
            if (isFavorite) {
              return ScaleTransition(
                scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                child: child,
              );
            }
            return FadeTransition(opacity: animation, child: child);
          },
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            size: 16.sp,
            color: AppColors.favIcon,
          ),
        ),
      ),
    );
  }
}
