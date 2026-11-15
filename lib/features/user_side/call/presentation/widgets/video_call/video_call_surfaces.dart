import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

// Both surfaces are const widgets wrapping their own narrowly-scoped
// BlocBuilder, so neither the parent's rebuilds nor the per-second duration
// timer (or other unrelated state ticks) ever reach them. Recreating
// VideoViewController on every tick tears down and reinitializes the native
// SurfaceView each time, which starves the MediaCodec decoder's
// BLASTBufferQueue ("already acquired max frames") and stutters playback —
// so these must only rebuild on real video changes.

/// Full-screen video: the remote feed once the other side joins, your own
/// camera before that.
class VideoCallMainSurface extends StatelessWidget {
  const VideoCallMainSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallScreenCubit, CallScreenState>(
      buildWhen: (previous, current) =>
          previous.isVideoMuted != current.isVideoMuted ||
          previous.isRemoteUserJoined != current.isRemoteUserJoined ||
          previous.remoteUid != current.remoteUid ||
          previous.isCallEnded != current.isCallEnded ||
          previous.session?.agoraChannel != current.session?.agoraChannel,
      builder: (context, state) {
        final engine = context.read<CallScreenCubit>().agoraEngine;

        // The call is over and the Agora engine is tearing down
        // (leaveChannel/dispose fire right after this transition) — stop
        // rendering a live video surface immediately instead of racing that
        // teardown, which is what froze the screen on call end.
        if (state.isCallEnded || engine == null) {
          return const SizedBox.shrink();
        }

        if (state.isRemoteUserJoined) {
          final remoteUid = state.remoteUid;
          final channelId = state.session?.agoraChannel;
          if (remoteUid == null || channelId == null || channelId.isEmpty) {
            return const SizedBox.shrink();
          }
          return AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(channelId: channelId),
            ),
          );
        }

        if (state.isVideoMuted) {
          return const VideoCameraOffFill(iconSize: 40);
        }

        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: engine,
            canvas: const VideoCanvas(
              uid: 0,
              sourceType: VideoSourceType.videoSourceCameraPrimary,
            ),
          ),
        );
      },
    );
  }
}

/// Your own camera inside the draggable picture-in-picture, once the other
/// side's feed has taken over the full screen.
class VideoCallSelfPreview extends StatelessWidget {
  const VideoCallSelfPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallScreenCubit, CallScreenState>(
      buildWhen: (previous, current) =>
          previous.isVideoMuted != current.isVideoMuted ||
          previous.isRemoteUserJoined != current.isRemoteUserJoined,
      builder: (context, state) {
        if (state.isVideoMuted) {
          return const VideoCameraOffFill(
            iconSize: 24,
            label: AppTexts.cameraOff,
          );
        }
        final engine = context.read<CallScreenCubit>().agoraEngine;
        if (engine == null) {
          return const VideoCameraOffFill(iconSize: 0, label: AppTexts.you);
        }
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: engine,
            canvas: const VideoCanvas(
              uid: 0,
              sourceType: VideoSourceType.videoSourceCameraPrimary,
            ),
          ),
        );
      },
    );
  }
}

/// Plum fill shown in place of a camera feed that's turned off (or not
/// available yet).
class VideoCameraOffFill extends StatelessWidget {
  final double iconSize;
  final String? label;

  const VideoCameraOffFill({super.key, required this.iconSize, this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.plumDeep],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconSize > 0)
              Icon(
                Icons.videocam_off_rounded,
                size: iconSize.csp,
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            if (label != null) ...[
              if (iconSize > 0) SizedBox(height: 6.cw),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 11.csp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
