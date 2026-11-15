import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/outgoing_call_launcher.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';

/// Presence, navigation and call/notify behaviour shared by the host grid
/// card ([UserGridItem]) and the list tile ([UserListTile]), so both layouts
/// act identically and only differ in arrangement.
mixin HostCardActions {
  HostEntity get host;

  /// When set, an online host gets one call button of this type instead of
  /// the generic call button that opens the type picker.
  CallType? get callType;

  // ── Derived presence helpers ─────────────────────────────────────────────

  bool get isOnline => host.presence?.isAvailableForCalls ?? false;
  bool get isBusy => host.presence?.isOnCall ?? false;

  bool get isVideoAvailable => host.presence?.videoAvailable ?? true;
  bool get isAudioAvailable => host.presence?.audioAvailable ?? true;

  // Maps presence state → the colour used for the status dot
  Color statusColor() {
    if (isOnline) return AppColors.onlineIndicator;
    if (isBusy) return AppColors.termsIcon;
    return AppColors.favIcon;
  }

  String statusLabel() {
    if (isOnline) return AppTexts.online;
    if (isBusy) return AppTexts.onCall;
    return AppTexts.offline;
  }

  String get displayName {
    if (host.fullName.isNotEmpty) return host.fullName;
    if (host.id.isEmpty) return 'Host';
    return 'Host (${host.id.length > 6 ? host.id.substring(0, 6) : host.id})';
  }

  void openProfile(BuildContext context) {
    // `host.isFavorite` is never populated by `HomeCubit` (favorite status
    // lives separately in `HomeState.favoriteIds`, sourced from the backend
    // favorites list) — stamp the real value on before handing the entity
    // to the profile screen, or its favorite icon starts stale/unfavorited
    // regardless of what's shown here on the grid.
    final isFavorite = context.read<HomeCubit>().state.favoriteIds.contains(
      host.id,
    );
    Navigator.pushNamed(
      context,
      AppRoutes.hostProfileScreen,
      arguments: host.copyWith(isFavorite: isFavorite),
    );
  }

  void startCall(BuildContext context, CallType callType, bool isAvailable) {
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${host.fullName} is currently not accepting calls.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    launchOutgoingCall(context, host: host, callType: callType);
  }

  /// Call button for an online host, "Notify Me" for everyone else.
  Widget buildCallAction(BuildContext context) {
    return switch ((isOnline, callType)) {
      (true, final CallType type) => _buildTypedCallButton(context, type),
      (true, null) => _buildCallButton(
        icon: isAudioAvailable ? Icons.call_rounded : Icons.videocam_rounded,
        enabled: isAudioAvailable || isVideoAvailable,
        onPressed: () => _onCallPressed(context),
      ),
      (false, _) => _buildNotifyButton(context),
    };
  }

  /// Both call types open the type picker; a single one calls straight away.
  void _onCallPressed(BuildContext context) {
    pickCallTypeThen(context, host, (type) => startCall(context, type, true));
  }

  Widget _buildTypedCallButton(BuildContext context, CallType type) {
    final isVideo = type == CallType.video;
    final isAvailable = isVideo ? isVideoAvailable : isAudioAvailable;
    return _buildCallButton(
      icon: isVideo ? Icons.videocam_rounded : Icons.call_rounded,
      enabled: isAvailable,
      onPressed: () => startCall(context, type, isAvailable),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    // Stays tappable when unavailable so the user gets the
    // "not accepting calls" explanation instead of a dead tap.
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: SizedBox(
        width: double.infinity,
        height: 30.cw,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            elevation: 0,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
          icon: Icon(icon, size: 16.csp),
          label: Text(
            AppTexts.call,
            style: TextStyle(fontSize: 12.csp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30.cw,
      child: OutlinedButton(
        onPressed: () => context.read<HomeCubit>().notifyUser(host),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.primaryColor,
          side: BorderSide(color: AppColors.primaryColor, width: 1.cw),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          AppTexts.notifyMe,
          style: TextStyle(
            fontSize: 11.csp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget buildPhoto() {
    if (host.avatarUrl.isEmpty) return _buildPlaceholderAvatar();
    if (host.avatarUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: host.avatarUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: AppColors.lightGrey),
        errorWidget: (context, url, error) => _buildPlaceholderAvatar(),
      );
    }
    return Image.asset(host.avatarUrl, fit: BoxFit.cover);
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: AppColors.lightGrey,
      child: Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
    );
  }
}

/// Heart toggle on a host card, backed by [HomeState.favoriteIds].
class HostFavoriteButton extends StatelessWidget {
  final String hostId;

  const HostFavoriteButton({super.key, required this.hostId});

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.select<HomeCubit, bool>(
      (cubit) => cubit.state.favoriteIds.contains(hostId),
    );

    return GestureDetector(
      onTap: () => context.read<HomeCubit>().toggleFavorite(hostId),
      child: Container(
        padding: EdgeInsets.all(4.cw),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: isFavorite ? 400 : 200),
          transitionBuilder: (child, animation) {
            // Favoriting gets a bouncy pop-in; unfavoriting just fades —
            // the pop is the "you just added this" feedback, so it only
            // belongs on the way in.
            if (isFavorite) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: child,
              );
            }
            return FadeTransition(opacity: animation, child: child);
          },
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(isFavorite),
            size: 14.csp,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
