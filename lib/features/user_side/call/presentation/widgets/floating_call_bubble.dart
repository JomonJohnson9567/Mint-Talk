import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/cubit/floating_call_bubble_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';

// Video calls float as a portrait card so the remote video keeps a natural
// phone-camera aspect ratio; audio calls float as a compact horizontal pill.
const double _kVideoWidth = 112;
const double _kVideoHeight = 160;
const double _kAudioWidth = 150;
const double _kAudioHeight = 56;
const double _kBubbleMargin = 16;

const Duration _kPulseDuration = Duration(milliseconds: 1200);

/// Brings a minimized, still-running call back to the full [CallScreen] —
/// from the bubble, the ongoing-call notification, or entering the system
/// picture-in-picture window (which should show the call, not whichever
/// screen happened to be on top). No-op when the call isn't minimized.
void restoreMinimizedCall(CallScreenCubit cubit) {
  final state = cubit.state;
  if (!state.isMinimized ||
      state.status == CallScreenStatus.initial ||
      state.isCallEnded) {
    return;
  }
  cubit.restoreCall();
  getIt<NavigationService>().navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const CallScreen()),
  );
}

String _formatDuration(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';
}

List<BoxShadow> get _floatingShadow => [
  BoxShadow(
    color: AppColors.black.withValues(alpha: 0.28),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
];

ImageProvider _avatarProvider(String? avatarUrl) {
  if (avatarUrl?.isNotEmpty != true) {
    return const AssetImage(AppAssets.maleIcon);
  }
  return avatarUrl!.startsWith('http')
      ? NetworkImage(avatarUrl)
      : AssetImage(avatarUrl) as ImageProvider;
}

/// App-wide floating "in call" preview — shown whenever [CallScreenCubit]'s
/// state is minimized (back was pressed on [CallScreen] mid-call). The call
/// itself keeps running underneath regardless of whether this preview or the
/// full [CallScreen] is what's currently visible; tapping the preview
/// restores the full screen, tapping its end-call button hangs up directly.
///
/// Mounted once in `app.dart`, above the app's `Navigator`, so it survives
/// and floats over any in-app screen the user navigates to while minimized.
/// Because it sits above the Navigator it has no Material ancestor, so the
/// subtree is wrapped in a transparent [Material] to give text a proper
/// default style (otherwise Flutter's debug yellow underline shows).
class FloatingCallBubble extends StatelessWidget {
  const FloatingCallBubble({super.key});

  // Ended-while-minimized must still restore (so CallScreenContents runs
  // its end-of-call summary/pop logic), which restoreMinimizedCall skips.
  static void _restoreToFullScreen(BuildContext context) {
    context.read<CallScreenCubit>().restoreCall();
    getIt<NavigationService>().navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const CallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallScreenCubit, CallScreenState>(
      // The call ending while minimized has no visible CallScreen listening
      // for it — restore to full screen so the existing, unchanged
      // end-of-call summary/pop logic in CallScreenContents can run.
      listenWhen: (previous, current) =>
          current.isCallEnded && !previous.isCallEnded && current.isMinimized,
      listener: (context, state) => _restoreToFullScreen(context),
      buildWhen: (previous, current) =>
          previous.isMinimized != current.isMinimized ||
          previous.status != current.status ||
          previous.isRemoteUserJoined != current.isRemoteUserJoined ||
          previous.remoteUid != current.remoteUid ||
          previous.isVideoMuted != current.isVideoMuted ||
          previous.durationSeconds != current.durationSeconds ||
          previous.displayName != current.displayName ||
          previous.avatarUrl != current.avatarUrl ||
          previous.session?.callType != current.session?.callType,
      builder: (context, state) {
        final visible =
            state.isMinimized &&
            state.status != CallScreenStatus.initial &&
            !state.isCallEnded;
        if (!visible) return const SizedBox.shrink();

        final cubit = context.read<CallScreenCubit>();
        final screenSize = MediaQuery.of(context).size;
        final isVideo = state.session?.callType.isVideo ?? false;
        final width = (isVideo ? _kVideoWidth : _kAudioWidth).w;
        final height = (isVideo ? _kVideoHeight : _kAudioHeight).w;
        final margin = _kBubbleMargin.w;

        return BlocProvider(
          create: (_) => FloatingCallBubbleCubit(
            width: width,
            height: height,
            boundaryWidth: screenSize.width,
            boundaryHeight: screenSize.height,
            margin: margin,
          ),
          child: Builder(
            builder: (context) {
              context.read<FloatingCallBubbleCubit>().syncBoundary(
                width: width,
                height: height,
                boundaryWidth: screenSize.width,
                boundaryHeight: screenSize.height,
                margin: margin,
              );

              return BlocBuilder<
                FloatingCallBubbleCubit,
                FloatingCallBubbleState
              >(
                builder: (context, dragState) {
                  final dragCubit = context.read<FloatingCallBubbleCubit>();
                  return AnimatedPositioned(
                    duration: dragState.isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    left: dragState.offset.dx,
                    top: dragState.offset.dy,
                    width: width,
                    height: height,
                    child: Material(
                      type: MaterialType.transparency,
                      child: GestureDetector(
                        onPanStart: (_) => dragCubit.dragStart(),
                        onPanUpdate: (details) =>
                            dragCubit.dragUpdate(details.delta),
                        onPanEnd: (_) => dragCubit.dragEnd(),
                        onTap: () => _restoreToFullScreen(context),
                        child: isVideo
                            ? _VideoPreviewCard(
                                state: state,
                                cubit: cubit,
                                onEndCall: cubit.endCall,
                              )
                            : _AudioPreviewPill(
                                state: state,
                                height: height,
                                onEndCall: cubit.endCall,
                              ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

/// Portrait card: live remote video (or avatar fallback) with a bottom
/// gradient bar holding a live dot, the running timer and an end button.
class _VideoPreviewCard extends StatelessWidget {
  final CallScreenState state;
  final CallScreenCubit cubit;
  final VoidCallback onEndCall;

  const _VideoPreviewCard({
    required this.state,
    required this.cubit,
    required this.onEndCall,
  });

  bool get _showRemoteVideo =>
      cubit.agoraEngine != null &&
      state.isRemoteUserJoined &&
      !state.isVideoMuted &&
      state.remoteUid != null &&
      state.session?.agoraChannel?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.r);

    // Shadow lives on the outer box, outside the clip, so it isn't cut off.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: _floatingShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          color: AppColors.callVideoBase,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_showRemoteVideo)
                AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: cubit.agoraEngine!,
                    canvas: VideoCanvas(uid: state.remoteUid),
                    connection: RtcConnection(
                      channelId: state.session!.agoraChannel!,
                    ),
                  ),
                )
              else
                Center(
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: CircleAvatar(
                      radius: 30.w,
                      backgroundColor: AppColors.lightGrey,
                      backgroundImage: _avatarProvider(state.avatarUrl),
                    ),
                  ),
                ),

              // Expand hint — tapping anywhere restores the full call.
              Positioned(
                top: 8.w,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black.withValues(alpha: 0.35),
                  ),
                  child: Icon(
                    Icons.open_in_full_rounded,
                    size: 12.sp,
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10.w, 16.w, 6.w, 6.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparent,
                        AppColors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      _PulsingDot(size: 6.w),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: _TimerText(
                            seconds: state.durationSeconds,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _EndCallButton(size: 28.w, onTap: onEndCall),
                    ],
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

/// Horizontal plum pill: breathing avatar, "On call" + timer, end button.
class _AudioPreviewPill extends StatelessWidget {
  final CallScreenState state;
  final double height;
  final VoidCallback onEndCall;

  const _AudioPreviewPill({
    required this.state,
    required this.height,
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.plumDeep, AppColors.primaryColor],
        ),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: _floatingShadow,
      ),
      child: Row(
        children: [
          _BreathingAvatar(size: 40.w, avatarUrl: state.avatarUrl),
          SizedBox(width: 8.w),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On call',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.7),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  _TimerText(seconds: state.durationSeconds, fontSize: 13.sp),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.w),
          _EndCallButton(size: 34.w, onTap: onEndCall),
        ],
      ),
    );
  }
}

class _TimerText extends StatelessWidget {
  final int seconds;
  final double fontSize;

  const _TimerText({required this.seconds, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(seconds),
      maxLines: 1,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 0.3,
        decoration: TextDecoration.none,
        fontFeatures: const [FontFeature.tabularFigures()],
        shadows: const [Shadow(color: Colors.black38, blurRadius: 3)],
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const _EndCallButton({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Own GestureDetector so the tap wins over the card's restore tap.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.callEndedStatus,
          boxShadow: [
            BoxShadow(
              color: AppColors.callEndedStatus.withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.call_end_rounded,
          color: AppColors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// Small green "live" dot that gently fades in and out.
class _PulsingDot extends StatefulWidget {
  final double size;

  const _PulsingDot({required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _kPulseDuration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.callBreathingGlow,
          boxShadow: [
            BoxShadow(
              color: AppColors.callBreathingGlow.withValues(alpha: 0.6),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar with a softly breathing green ring behind it.
class _BreathingAvatar extends StatefulWidget {
  final double size;
  final String? avatarUrl;

  const _BreathingAvatar({required this.size, required this.avatarUrl});

  @override
  State<_BreathingAvatar> createState() => _BreathingAvatarState();
}

class _BreathingAvatarState extends State<_BreathingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _kPulseDuration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_controller.value);
              return Transform.scale(
                scale: 1.0 + 0.15 * t,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.lerp(
                      AppColors.callBreathingGlow,
                      AppColors.callBreathingGlowSoft,
                      t,
                    )!.withValues(alpha: 0.55 * (1 - t) + 0.2),
                  ),
                ),
              );
            },
          ),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.callBreathingGlow,
            ),
            child: CircleAvatar(
              radius: size / 2 - 2.w,
              backgroundColor: AppColors.lightGrey,
              backgroundImage: _avatarProvider(widget.avatarUrl),
            ),
          ),
        ],
      ),
    );
  }
}
