import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/outgoing_call_launcher.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_state.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';

/// One call in the history: avatar (with a live online dot), name, call type,
/// time + duration and a call-back button.
class CallLogItem extends StatelessWidget {
  final CallLogEntry entry;
  final bool showDivider;

  const CallLogItem({super.key, required this.entry, this.showDivider = true});

  static const double _avatarSize = 56;

  @override
  Widget build(BuildContext context) {
    // HomeCubit (provided by MainNavigationScreen) holds the live host list
    // with socket presence — the call log API only returns name and avatar.
    final host = context.select<HomeCubit, HostEntity?>(
      (cubit) => cubit.state.hosts
          .where((h) => h.id == entry.hostId && entry.hostId.isNotEmpty)
          .firstOrNull,
    );
    final isOnline = host?.presence?.isAvailableForCalls ?? false;
    final accent = entry.isMissed ? AppColors.audioAccent : AppColors.plumMuted;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.cw),
          child: Row(
            children: [
              _Avatar(imageUrl: entry.imageUrl, isOnline: isOnline),
              SizedBox(width: 14.cw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 16.5.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    SizedBox(height: 6.cw),
                    Row(
                      children: [
                        Icon(
                          entry.isVideoCall
                              ? Icons.videocam_rounded
                              : Icons.call_rounded,
                          size: 17.csp,
                          color: entry.isMissed
                              ? AppColors.audioAccent
                              : AppColors.primaryColor,
                        ),
                        SizedBox(width: 8.cw),
                        Flexible(
                          child: Text(
                            _typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5.csp,
                              fontWeight: FontWeight.w500,
                              color: accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.cw),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(entry.createdAt),
                    style: TextStyle(
                      fontSize: 13.csp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.plumMuted,
                    ),
                  ),
                  SizedBox(height: 6.cw),
                  Text(
                    entry.isMissed
                        ? AppTexts.missed
                        : _formatDuration(entry.durationSeconds),
                    style: TextStyle(
                      fontSize: 13.csp,
                      fontWeight: entry.isMissed
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: accent,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.cw),
              _CallBackButton(
                tooltip: entry.isVideoCall
                    ? AppTexts.videoCallLabel
                    : AppTexts.audioCallLabel,
                onTap: () => _callBack(context, host),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: (_avatarSize + 14).cw,
            color: AppColors.profileDivider,
          ),
      ],
    );
  }

  String get _typeLabel {
    if (entry.isMissed) {
      return entry.isVideoCall
          ? AppTexts.missedVideoCall
          : AppTexts.missedAudioCall;
    }
    return entry.isVideoCall
        ? AppTexts.videoCallLabel
        : AppTexts.audioCallLabel;
  }

  void _callBack(BuildContext context, HostEntity? host) {
    final callType = entry.isVideoCall ? CallType.video : CallType.audio;
    final isTypeAvailable = callType.isVideo
        ? host?.presence?.videoAvailable ?? true
        : host?.presence?.audioAvailable ?? true;
    final isAvailable =
        host != null &&
        (host.presence?.isAvailableForCalls ?? false) &&
        isTypeAvailable;

    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.hostNotAvailable),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    launchOutgoingCall(context, host: host, callType: callType);
  }

  /// `09:15 PM`
  static String _formatTime(DateTime? time) {
    if (time == null) return '';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// `02:24`, or `1:02:24` once a call passes an hour.
  static String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
    }
    return '${minutes.toString().padLeft(2, '0')}:$seconds';
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;

  const _Avatar({required this.imageUrl, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final size = CallLogItem._avatarSize.cw;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: imageUrl.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Image.asset(AppAssets.femaleIcon, fit: BoxFit.cover),
                    )
                  : Image.asset(
                      imageUrl.isNotEmpty ? imageUrl : AppAssets.femaleIcon,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 2.cw,
              child: Container(
                width: 15.cw,
                height: 15.cw,
                decoration: BoxDecoration(
                  color: AppColors.onlineIndicator,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.5.cw),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CallBackButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onTap;

  const _CallBackButton({required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.audioBtnBg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 46.cw,
            height: 46.cw,
            child: Icon(
              Icons.call_rounded,
              size: 21.csp,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
