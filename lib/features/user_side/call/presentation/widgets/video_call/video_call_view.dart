import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/cubit/call_background_ui_cubit.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_header.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_status_text.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/audio_route_sheet.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/call_device_status_chips.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_fit_layout.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_network_banner.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/draggable_video_preview.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/video_call/pip_call_overlay.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/video_call/video_call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/video_call/video_call_ringing_avatar.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/video_call/video_call_surfaces.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/video_call/video_call_top_bar.dart';

/// Full-screen layout for video calls. Before the call connects your own
/// camera fills the screen behind a ringing mascot and the call status;
/// once active the other side's feed takes over, with your camera in a
/// draggable picture-in-picture and auto-hiding controls. The shared
/// listeners live in `CallScreenContents`.
///
/// In the system picture-in-picture window (app left mid-call, Android)
/// only the main video and a small timer remain — the window is too small
/// and not touchable, and its controls are the native PiP actions. The
/// main surface stays at the same position in the tree either way, so
/// entering/leaving PiP never recreates the native video view.
class VideoCallView extends StatelessWidget {
  final CallScreenState state;

  const VideoCallView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallScreenCubit>();
    final isActive = state.status == CallScreenStatus.active;
    // The auto-hide toggle in state is only meaningful while the call is
    // active (that's the only time CallScreenCubit schedules the timer that
    // flips it) — outside that window controls are always shown.
    final controlsVisible = !isActive || state.controlsVisible;
    final topInset = MediaQuery.paddingOf(context).top;
    final isInPip = context.select<CallBackgroundUiCubit, bool>(
      (c) => c.state.isInPip,
    );

    final controls = VideoCallControls(
      isMuted: state.isMuted,
      isVideoMuted: state.isVideoMuted,
      audioRoute: state.audio.route,
      isCallActive: isActive,
      onToggleMute: cubit.toggleMuteAudio,
      onToggleVideo: cubit.toggleMuteVideo,
      onAudioRouteTap: () => AudioRouteSheet.openOrToggle(context),
      onEndCall: cubit.endCall,
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isActive && !isInPip ? cubit.showControls : null,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: AppColors.callVideoBase),
          ),
          const Positioned.fill(child: VideoCallMainSurface()),
          if (isInPip)
            const PipCallOverlay()
          else ...[
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: controlsVisible ? 1 : 0,
                  child: _Scrims(isActive: isActive),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 16.cw),
                child: isActive
                    ? AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: controlsVisible ? 1 : 0,
                        child: IgnorePointer(
                          ignoring: !controlsVisible,
                          child: Column(
                            children: [
                              VideoCallTopBar(name: state.displayName),
                              const CallDeviceStatusChips(onDark: true),
                              Expanded(
                                child: CallControlsFirstLayout(
                                  middle: const SizedBox.shrink(),
                                  bottom: controls,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          AudioCallHeader(
                            name: state.displayName,
                            icon: Icons.videocam_rounded,
                            label: AppTexts.videoCallLabel,
                            onDark: true,
                          ),
                          Expanded(
                            child: CallControlsFirstLayout(
                              middle: ScaleDownToFit(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const VideoCallRingingAvatar(),
                                    SizedBox(height: 36.cw),
                                    AudioCallStatusText(
                                      state: state,
                                      onDark: true,
                                    ),
                                    const CallDeviceStatusChips(onDark: true),
                                  ],
                                ),
                              ),
                              bottom: controls,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Positioned(
              top: topInset + (isActive ? 68.cw : 8.cw),
              left: 0,
              right: 0,
              child: const CallNetworkBanner(),
            ),
            // Your camera moves into the picture-in-picture once the other
            // side's feed takes over the full screen. Its drag area starts
            // below the top bar.
            if (state.isRemoteUserJoined)
              Positioned(
                top: topInset + 60.cw,
                left: 0,
                right: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    children: [
                      DraggableVideoPreview(
                        boundaryWidth: constraints.maxWidth,
                        boundaryHeight: constraints.maxHeight,
                        width: 104.cw,
                        height: 148.cw,
                        margin: 16.cw,
                        borderRadius: BorderRadius.circular(18.cw),
                        child: DecoratedBox(
                          position: DecorationPosition.foreground,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.cw),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.9),
                              width: 2,
                            ),
                          ),
                          child: const VideoCallSelfPreview(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Plum gradients at the top and bottom so white text and controls stay
/// readable over any camera feed. Taller before the call connects, when the
/// header and status text sit over the feed.
class _Scrims extends StatelessWidget {
  final bool isActive;

  const _Scrims({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: (isActive ? 180 : 300).cw,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.plumDeep.withValues(alpha: isActive ? 0.6 : 0.82),
                  AppColors.plumDeep.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: (isActive ? 340 : 460).cw,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.callGlassDark.withValues(
                    alpha: isActive ? 0.75 : 0.92,
                  ),
                  AppColors.callGlassDark.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
