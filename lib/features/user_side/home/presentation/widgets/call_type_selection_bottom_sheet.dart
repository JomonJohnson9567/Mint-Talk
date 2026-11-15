import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/rate_formatter.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/outgoing_call_launcher.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';

class CallTypeSelectionBottomSheet extends StatelessWidget {
  final HostEntity host;

  /// Overrides the default [launchOutgoingCall] once a type is picked.
  final void Function(CallType callType)? onSelected;

  const CallTypeSelectionBottomSheet({
    super.key,
    required this.host,
    this.onSelected,
  });

  static Future<void> show(
    BuildContext context,
    HostEntity host, {
    void Function(CallType callType)? onSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          CallTypeSelectionBottomSheet(host: host, onSelected: onSelected),
    );
  }

  void _onSelectCallType(BuildContext context, CallType callType) {
    final navigator = Navigator.of(context);
    navigator.pop(); // Close bottom sheet
    if (onSelected != null) {
      onSelected!(callType);
      return;
    }
    // The sheet's own context is on its way out — launch from the
    // navigator's context so the balance prompt / call screen attach to a
    // context that stays mounted.
    launchOutgoingCall(navigator.context, host: host, callType: callType);
  }

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${host.fullName} is currently not accepting calls.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Clients are billed at the app-wide system-config rates, which are
    // already in billingUnit, so they're shown without conversion.
    final config = context.watch<SystemConfigCubit>().state;
    final balance = context.select<WalletCubit, int>(
      (cubit) => cubit.state.balance,
    );
    final isVideoAvailable = host.presence?.videoAvailable ?? true;
    final isAudioAvailable = host.presence?.audioAvailable ?? true;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(16.cw, 10.cw, 16.cw, 12.cw),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.cw,
                height: 4.cw,
                decoration: BoxDecoration(
                  color: AppColors.lavenderBorder,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 14.cw),
            _HostHeader(host: host),
            SizedBox(height: 18.cw),
            Text(
              AppTexts.chooseCallType,
              style: TextStyle(
                fontSize: 15.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 12.cw),
            Row(
              children: [
                Expanded(
                  child: _CallOptionCard(
                    icon: Icons.videocam_rounded,
                    title: AppTexts.videoCall,
                    rateText: RateFormatter.raw(
                      config.defaultVideoRate,
                      config.billingUnit,
                      unit: 'coins',
                    ),
                    background: AppColors.videoCardBg,
                    accent: AppColors.primaryColor,
                    available: isVideoAvailable,
                    entranceDuration: const Duration(milliseconds: 250),
                    onTap: () => isVideoAvailable
                        ? _onSelectCallType(context, CallType.video)
                        : _showUnavailable(context),
                  ),
                ),
                SizedBox(width: 10.cw),
                Expanded(
                  child: _CallOptionCard(
                    icon: Icons.call_rounded,
                    title: AppTexts.audioCall,
                    rateText: RateFormatter.raw(
                      config.defaultAudioRate,
                      config.billingUnit,
                      unit: 'coins',
                    ),
                    background: AppColors.audioCardBg,
                    accent: AppColors.audioAccent,
                    available: isAudioAvailable,
                    entranceDuration: const Duration(milliseconds: 330),
                    onTap: () => isAudioAvailable
                        ? _onSelectCallType(context, CallType.audio)
                        : _showUnavailable(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.cw),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppAssets.rechargeCoin, width: 16.cw),
                  SizedBox(width: 6.cw),
                  Text(
                    '${AppTexts.yourBalance}: $balance coins',
                    style: TextStyle(
                      fontSize: 12.csp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.plumMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Host avatar, name and online status on the mascot banner. The mascot
/// image is opaque — its background matches [AppColors.greetingBanner], so
/// it reads as part of the banner.
class _HostHeader extends StatelessWidget {
  final HostEntity host;

  const _HostHeader({required this.host});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 80.cw),
      decoration: BoxDecoration(
        color: AppColors.greetingBanner,
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(width: 14.cw),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52.cw,
                height: 52.cw,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.5.cw),
                ),
                child: ClipOval(child: _buildAvatar()),
              ),
              Positioned(
                right: 1.cw,
                bottom: 1.cw,
                child: Container(
                  width: 13.cw,
                  height: 13.cw,
                  decoration: BoxDecoration(
                    color: AppColors.onlineIndicator,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2.cw),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.cw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  host.fullName.isNotEmpty ? host.fullName : 'Host',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                  ),
                ),
                SizedBox(height: 3.cw),
                Text(
                  AppTexts.readyToTalk,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.csp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onlineIndicator,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(AppAssets.homeMascot, height: 80.cw, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final placeholder = Container(
      color: AppColors.lightGrey,
      child: Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
    );
    if (host.avatarUrl.isEmpty) return placeholder;
    if (host.avatarUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: host.avatarUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: AppColors.lightGrey),
        errorWidget: (context, url, error) => placeholder,
      );
    }
    return Image.asset(host.avatarUrl, fit: BoxFit.cover);
  }
}

/// Call-type card matching the home screen's video/audio cards. Fades and
/// slides in over [entranceDuration] (staggered per card), and shrinks
/// slightly while pressed.
class _CallOptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String rateText;
  final Color background;
  final Color accent;
  final bool available;
  final Duration entranceDuration;
  final VoidCallback onTap;

  const _CallOptionCard({
    required this.icon,
    required this.title,
    required this.rateText,
    required this.background,
    required this.accent,
    required this.available,
    required this.entranceDuration,
    required this.onTap,
  });

  @override
  State<_CallOptionCard> createState() => _CallOptionCardState();
}

class _CallOptionCardState extends State<_CallOptionCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: widget.entranceDuration,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 18.cw),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          // Unavailable cards stay tappable so the user gets the
          // "not accepting calls" explanation instead of a dead tap.
          child: Opacity(
            opacity: widget.available ? 1 : 0.45,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.cw, vertical: 16.cw),
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: widget.accent.withValues(alpha: 0.10),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 50.cw,
                    height: 50.cw,
                    decoration: BoxDecoration(
                      color: widget.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: AppColors.white,
                      size: 24.csp,
                    ),
                  ),
                  SizedBox(height: 10.cw),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 14.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                    ),
                  ),
                  SizedBox(height: 8.cw),
                  _buildFooterChip(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterChip() {
    if (!widget.available) {
      return _chip(
        child: Text(
          AppTexts.unavailable,
          style: TextStyle(
            fontSize: 11.csp,
            fontWeight: FontWeight.w700,
            color: AppColors.subtitleText,
          ),
        ),
      );
    }
    return _chip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AppAssets.rechargeCoin, width: 13.cw),
          SizedBox(width: 4.cw),
          Flexible(
            child: Text(
              widget.rateText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.csp,
                fontWeight: FontWeight.w700,
                color: widget.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({required Widget child}) {
    return Container(
      height: 22.cw,
      padding: EdgeInsets.symmetric(horizontal: 8.cw),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(11.r),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
