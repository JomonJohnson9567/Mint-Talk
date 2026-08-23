import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_ended_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_profile_avatar.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_summary_dialog.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/caller_identity_chip.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/draggable_video_preview.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';

/// Display data (name, avatar, host/caller role) is read from
/// [CallScreenCubit]'s state rather than passed in as constructor args — the
/// cubit lives at the app root and outlives this widget, and a
/// bubble-triggered restore re-mounts this widget with nothing else to
/// source that data from.
class CallScreenContents extends StatelessWidget {
  const CallScreenContents({super.key});

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Network conditions take priority and render regardless of the
  /// top-level [CallScreenStatus] — a mid-call blip (the common case) still
  /// happens while `status == active`, not just during the initial join.
  String _statusLabel(CallScreenState state) {
    if (state.isCallEnded) {
      return 'Call Ended';
    }
    if (state.networkStatus.isLocalDeviceOffline) {
      return "You're offline. Trying to reconnect…";
    }
    if (state.networkStatus.isRemoteReconnecting) {
      return "Other participant's connection is unstable…";
    }
    if (state.mediaStatus == CallMediaStatus.reconnecting) {
      return 'Reconnecting...';
    }

    return state.status == CallScreenStatus.active
        ? _formatDuration(state.durationSeconds)
        : state.status == CallScreenStatus.ringing
        ? 'Ringing...'
        : state.status == CallScreenStatus.connecting
        ? (switch (state.mediaStatus) {
            CallMediaStatus.requestingPermissions => 'Checking permissions...',
            CallMediaStatus.initializing => 'Initializing connection...',
            CallMediaStatus.joining => 'Joining media session...',
            CallMediaStatus.waitingForRemote => 'Connecting media...',
            CallMediaStatus.reconnecting => 'Reconnecting...',
            _ => 'Connecting media...',
          })
        : state.status == CallScreenStatus.initiating
        ? 'Calling...'
        : state.status == CallScreenStatus.ended
        ? 'Call Ended'
        : 'Connecting...';
  }

  /// True when [_statusLabel] would resolve to nothing but the elapsed
  /// duration — i.e. the call is active with a healthy connection — which
  /// is already shown by the top-left [CallerIdentityChip] timer.
  bool _isDuplicateTimerLabel(CallScreenState state) {
    return state.status == CallScreenStatus.active &&
        !state.networkStatus.isLocalDeviceOffline &&
        !state.networkStatus.isRemoteReconnecting &&
        state.mediaStatus != CallMediaStatus.reconnecting;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallScreenCubit, CallScreenState>(
      // Skips rebuilds that are purely the once-a-second duration tick
      // during a healthy active call — nothing this builder renders depends
      // on the duration value itself in that case (CallerIdentityChip owns
      // the visible timer via its own independent BlocBuilder below).
      buildWhen: (previous, current) {
        final durationOnlyChange =
            previous.durationSeconds != current.durationSeconds &&
            previous.copyWith(durationSeconds: current.durationSeconds) ==
                current;
        final isHealthyActive =
            current.status == CallScreenStatus.active &&
            !current.networkStatus.hasNetworkIssue &&
            current.mediaStatus != CallMediaStatus.reconnecting;
        return !(durationOnlyChange && isHealthyActive);
      },
      listenWhen: (previous, current) {
        final enteredFailed =
            current.status == CallScreenStatus.failed &&
            previous.status != CallScreenStatus.failed;
        final enteredEnded = current.isCallEnded && !previous.isCallEnded;
        return enteredFailed || enteredEnded;
      },
      listener: handleCallEndedTransition,
      builder: (context, state) {
        final cubit = context.read<CallScreenCubit>();
        final isVideo = (state.session?.callType ?? CallType.audio).isVideo;
        final agoraEngine = cubit.agoraEngine;
        // The auto-hide toggle in state is only meaningful while a video
        // call is active (that's the only time CallScreenCubit schedules
        // the timer that flips it) — outside that window controls are
        // always shown, regardless of the raw flag's last value.
        final controlsVisible =
            !(isVideo && state.status == CallScreenStatus.active) ||
            state.controlsVisible;

        return SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: isVideo && state.status == CallScreenStatus.active
                ? cubit.showControls
                : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Video surfaces are isolated in their own BlocBuilder so the
                    // per-second duration timer (and other unrelated state ticks)
                    // never rebuild them. Recreating VideoViewController on every
                    // tick tears down and reinitializes the native SurfaceView
                    // each time, which starves the MediaCodec decoder's
                    // BLASTBufferQueue ("already acquired max frames") and stutters
                    // playback — so these must only rebuild on real video changes.
                    if (isVideo && agoraEngine != null)
                      Positioned.fill(
                        child: BlocBuilder<CallScreenCubit, CallScreenState>(
                          buildWhen: (previous, current) =>
                              previous.isVideoMuted != current.isVideoMuted ||
                              previous.isRemoteUserJoined !=
                                  current.isRemoteUserJoined ||
                              previous.remoteUid != current.remoteUid ||
                              previous.isCallEnded != current.isCallEnded ||
                              previous.session?.agoraChannel !=
                                  current.session?.agoraChannel,
                          builder: (context, videoState) {
                            // The call is over and the Agora engine is tearing
                            // down (leaveChannel/dispose fire right after this
                            // transition) — stop rendering a live video surface
                            // immediately instead of racing that teardown, which
                            // is what froze the screen on call end.
                            if (videoState.isCallEnded) {
                              return const SizedBox.shrink();
                            }

                            if (videoState.isRemoteUserJoined) {
                              final remoteUid = videoState.remoteUid;
                              final channelId =
                                  videoState.session?.agoraChannel;
                              if (remoteUid == null ||
                                  channelId == null ||
                                  channelId.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return AgoraVideoView(
                                controller: VideoViewController.remote(
                                  rtcEngine: agoraEngine,
                                  canvas: VideoCanvas(uid: remoteUid),
                                  connection: RtcConnection(
                                    channelId: channelId,
                                  ),
                                ),
                              );
                            }

                            if (videoState.isVideoMuted) {
                              return Container(
                                color: Colors.black87,
                                child: Center(
                                  child: Icon(
                                    Icons.videocam_off,
                                    color: Colors.white70,
                                    size: 42.sp,
                                  ),
                                ),
                              );
                            }

                            return AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: agoraEngine,
                                canvas: const VideoCanvas(
                                  uid: 0,
                                  sourceType:
                                      VideoSourceType.videoSourceCameraPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Overlay UI
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // Avatar (Audio calls only)
                          if (!isVideo)
                            CallProfileAvatar(
                              imagePath: state.avatarUrl?.isNotEmpty == true
                                  ? state.avatarUrl!
                                  : AppAssets.maleIcon,
                              isBreathingExpanded:
                                  state.status == CallScreenStatus.ringing,
                            ),

                          SizedBox(height: 24.h),

                          // Status Label — the name and duration are already
                          // shown in the top-left CallerIdentityChip, so the
                          // center only needs to surface transient status text
                          // (ringing/connecting/reconnecting/call ended). Once
                          // the call is active with a healthy connection, that
                          // label would just be the duration again, so it's
                          // hidden to avoid duplicating the top-left timer.
                          if (!_isDuplicateTimerLabel(state))
                            Text(
                              _statusLabel(state),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: isVideo && state.isRemoteUserJoined
                                    ? AppColors.primaryColor
                                    : AppColors.primaryColor,
                              ),
                            ),

                          const Spacer(flex: 3),

                          // Call Controls
                          // The post-call "Close / Add to Favorites / Call again"
                          // panel is a user-only affordance — hosts are popped
                          // straight back to their dashboard (see listener above),
                          // so nothing should render here for them.
                          if (state.isCallEnded)
                            state.isHost
                                ? const SizedBox.shrink()
                                : CallEndedControls(
                                    onCancel: () =>
                                        Navigator.of(context).maybePop(),
                                    onCallAgain: () {
                                      final targetHostId =
                                          state.session?.hostId;
                                      final targetCallType =
                                          state.session?.callType ??
                                          CallType.audio;
                                      if (targetHostId != null &&
                                          targetHostId.isNotEmpty) {
                                        cubit.startOutgoingCall(
                                          hostId: targetHostId,
                                          callType: targetCallType,
                                          displayName: state.displayName,
                                          avatarUrl: state.avatarUrl,
                                        );
                                      } else {
                                        Navigator.of(context).maybePop();
                                      }
                                    },
                                  )
                          else
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: controlsVisible ? 1 : 0,
                              child: IgnorePointer(
                                ignoring: !controlsVisible,
                                child: CallControls(
                                  isMuted: state.isMuted,
                                  isVideoMuted: state.isVideoMuted,
                                  isSpeakerOn: state.isSpeakerOn,
                                  isVideoCall: isVideo,
                                  onToggleMute: cubit.toggleMuteAudio,
                                  onToggleVideo: cubit.toggleMuteVideo,
                                  onToggleSpeaker: cubit.toggleSpeakerphone,
                                  onSwitchCamera: cubit.switchCamera,
                                  onEndCall: cubit.endCall,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Top-left overlay showing who this participant is talking
                    // to — their name, avatar, and the live call duration.
                    if (!state.isCallEnded)
                      Positioned(
                        top: 20.h,
                        left: 20.w,
                        child: CallerIdentityChip(
                          name: state.displayName,
                          avatarPath: state.avatarUrl,
                        ),
                      ),

                    // Weak-network banner. Isolated in its own narrowly-scoped
                    // BlocBuilder (buildWhen only on networkStatus) so it never
                    // triggers a rebuild of the video surfaces above.
                    Positioned(
                      top: 20.h,
                      left: 0,
                      right: 0,
                      child: BlocBuilder<CallScreenCubit, CallScreenState>(
                        buildWhen: (previous, current) =>
                            previous.networkStatus != current.networkStatus ||
                            previous.status != current.status,
                        builder: (context, netState) {
                          if (netState.isCallEnded ||
                              !netState.networkStatus.hasNetworkIssue) {
                            return const SizedBox.shrink();
                          }
                          final message =
                              netState.networkStatus.isLocalDeviceOffline
                              ? "You're offline"
                              : netState.networkStatus.isRemoteReconnecting
                              ? 'Other participant reconnecting…'
                              : 'Weak connection';
                          return Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Local Camera Preview Thumbnail for Video Calls
                    // Isolated in its own BlocBuilder for the same reason as the
                    // main video surface above — must not rebuild on every
                    // duration-timer tick.
                    if (isVideo)
                      DraggableVideoPreview(
                        boundaryWidth: constraints.maxWidth,
                        boundaryHeight: constraints.maxHeight,
                        width: 100.w,
                        height: 140.h,
                        margin: 20.w,
                        borderRadius: BorderRadius.circular(12.r),
                        child: BlocBuilder<CallScreenCubit, CallScreenState>(
                          buildWhen: (previous, current) =>
                              previous.isVideoMuted != current.isVideoMuted ||
                              previous.isRemoteUserJoined !=
                                  current.isRemoteUserJoined,
                          builder: (context, thumbState) {
                            if (!thumbState.isRemoteUserJoined) {
                              return const SizedBox.shrink();
                            }
                            if (thumbState.isVideoMuted) {
                              return Container(
                                color: Colors.black87,
                                child: Center(
                                  child: Icon(
                                    Icons.videocam_off,
                                    color: Colors.white70,
                                    size: 28.sp,
                                  ),
                                ),
                              );
                            }
                            if (agoraEngine == null) {
                              return Container(
                                color: Colors.black87,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                ),
                              );
                            }
                            return AgoraVideoView(
                              controller: VideoViewController(
                                rtcEngine: agoraEngine,
                                canvas: const VideoCanvas(
                                  uid: 0,
                                  sourceType:
                                      VideoSourceType.videoSourceCameraPrimary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Runs the call's "just ended/failed" side effects: a snackbar+pop for a
/// failed call, or the pop-then-summary-dialog sequence for a genuinely
/// ended call.
///
/// Called from two places: [CallScreenContents]'s own `BlocConsumer`
/// listener, for a live transition while the screen is visible — and from
/// [CallScreen] itself, when it mounts directly into an already-ended state
/// (e.g. restored from the floating bubble after the call ended while
/// minimized). flutter_bloc's `BlocListener` never replays a state that was
/// already current at the time it subscribed, so that second call site is
/// what covers this scenario — without it, a call ending while minimized
/// would silently strand the user on a screen with no exit and no summary.
void handleCallEndedTransition(BuildContext context, CallScreenState state) {
  if (state.status == CallScreenStatus.failed) {
    final isBusy =
        state.errorMessage.toLowerCase().contains('busy') ||
        state.errorMessage.toLowerCase().contains('another call') ||
        state.errorMessage.toLowerCase().contains('occupied') ||
        state.errorMessage.toLowerCase().contains('400') ||
        state.errorMessage.toLowerCase().contains('409');
    if (isBusy) {
      showTopSnackBar(context, "Host is busy right now. Please try again.");
    } else if (state.errorMessage.isNotEmpty) {
      showTopSnackBar(context, state.errorMessage);
    }
    Navigator.of(context).maybePop();
    return;
  }

  if (state.isCallEnded) {
    if (state.isHost) {
      // The call screen route and the summary dialog share the same
      // root Navigator (see NavigationService), so the dialog must be
      // pushed only *after* the call screen has actually been popped —
      // otherwise this deferred pop would land on top of the dialog
      // and dismiss it instead of the call screen.
      final shouldShowSummary =
          (state.durationSeconds > 0 ||
              state.status == CallScreenStatus.insufficientBalance) &&
          state.session != null;
      final session = state.session;

      // Pop after the current frame settles so this doesn't race the
      // video surface teardown above (which is what previously left
      // the host stuck on a frozen call screen instead of returning
      // to the dashboard).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // No route to pop (e.g. call screen was the root route) —
          // fall back to the app's navigator so the host isn't left
          // stranded on a dead screen.
          getIt<NavigationService>().navigatorKey.currentState?.popUntil(
            (route) => route.isFirst,
          );
        }

        if (shouldShowSummary && session != null) {
          final globalContext =
              getIt<NavigationService>().navigatorKey.currentContext;
          if (globalContext != null) {
            CallSummaryDialog.show(
              globalContext,
              session,
              state.isHost,
              localDurationSeconds: state.durationSeconds,
            );
          }
        }
      });
    } else {
      if (state.durationSeconds > 0 ||
          state.status == CallScreenStatus.insufficientBalance) {
        _showCallSummaryDialog(context, state);
      } else {
        // Do NOT pop immediately on other ended states (e.g. caller cancelled, host declined),
        // let it show the CallEndedControls!
      }
    }
  }
}

void _showCallSummaryDialog(BuildContext context, CallScreenState state) {
    final session = state.session;
    if (session != null) {
      CallSummaryDialog.show(
        context,
        session,
        state.isHost,
        localDurationSeconds: state.durationSeconds,
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 320.w,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.borderSoft, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.red,
                    size: 36.sp,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  state.status == CallScreenStatus.insufficientBalance
                      ? 'Insufficient Balance'
                      : 'Call Failed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : 'Could not establish connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.subtitleText,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(dialogCtx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

