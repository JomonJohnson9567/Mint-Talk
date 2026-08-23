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

const double _kBubbleSize = 64;
// Video calls float as a larger square so the remote video thumbnail stays
// legible instead of being clipped down into a tiny circle.
const double _kVideoBubbleSize = 120;
const double _kBubbleMargin = 16;

/// App-wide floating "in call" bubble — shown whenever [CallScreenCubit]'s
/// state is minimized (back was pressed on [CallScreen] mid-call). The call
/// itself keeps running underneath regardless of whether this bubble or the
/// full [CallScreen] is what's currently visible; tapping the bubble
/// restores the full screen, tapping its end-call badge hangs up directly.
///
/// Mounted once in `app.dart`, above the app's `Navigator`, so it survives
/// and floats over any in-app screen the user navigates to while minimized.
class FloatingCallBubble extends StatelessWidget {
  const FloatingCallBubble({super.key});

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
        final bubbleSize = (isVideo ? _kVideoBubbleSize : _kBubbleSize).w;

        return BlocProvider(
          create: (_) => FloatingCallBubbleCubit(
            size: bubbleSize,
            boundaryWidth: screenSize.width,
            boundaryHeight: screenSize.height,
            margin: _kBubbleMargin.w,
          ),
          child: Builder(
            builder: (context) {
              context.read<FloatingCallBubbleCubit>().syncBoundary(
                size: bubbleSize,
                boundaryWidth: screenSize.width,
                boundaryHeight: screenSize.height,
                margin: _kBubbleMargin.w,
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
                    width: bubbleSize,
                    height: bubbleSize,
                    child: GestureDetector(
                      onPanStart: (_) => dragCubit.dragStart(),
                      onPanUpdate: (details) =>
                          dragCubit.dragUpdate(details.delta),
                      onPanEnd: (_) => dragCubit.dragEnd(),
                      onTap: () => _restoreToFullScreen(context),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _BubbleContent(
                            state: state,
                            cubit: cubit,
                            size: bubbleSize,
                            isVideo: isVideo,
                            onEndCall: cubit.endCall,
                          ),
                          // Video's square bubble instead shows the end-call
                          // button stacked under the duration inside the
                          // square (see _BubbleContent) — the corner badge is
                          // only for the small round audio bubble.
                          if (!isVideo)
                            Positioned(
                              right: -4.w,
                              bottom: -4.w,
                              child: _EndCallBadge(onTap: cubit.endCall),
                            ),
                        ],
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

class _BubbleContent extends StatelessWidget {
  final CallScreenState state;
  final CallScreenCubit cubit;
  final double size;
  final bool isVideo;
  final VoidCallback onEndCall;

  const _BubbleContent({
    required this.state,
    required this.cubit,
    required this.size,
    required this.isVideo,
    required this.onEndCall,
  });

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final agoraEngine = cubit.agoraEngine;
    final radius = isVideo ? BorderRadius.circular(16.r) : BorderRadius.circular(size / 2);

    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: isVideo ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: isVideo ? radius : null,
          color: AppColors.callBackground,
          border: Border.all(color: AppColors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isVideo &&
                agoraEngine != null &&
                state.isRemoteUserJoined &&
                !state.isVideoMuted &&
                state.remoteUid != null &&
                state.session?.agoraChannel?.isNotEmpty == true)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: agoraEngine,
                  canvas: VideoCanvas(uid: state.remoteUid),
                  connection: RtcConnection(
                    channelId: state.session!.agoraChannel!,
                  ),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundColor: AppColors.lightGrey,
                  backgroundImage:
                      state.avatarUrl?.isNotEmpty == true
                          ? (state.avatarUrl!.startsWith('http')
                                    ? NetworkImage(state.avatarUrl!)
                                    : AssetImage(state.avatarUrl!))
                                as ImageProvider
                          : const AssetImage(AppAssets.maleIcon),
                ),
              ),

            // Running duration, overlaid at the bottom so it reads on top of
            // either the avatar or the live video thumbnail. The video
            // square additionally stacks the end-call button right under it
            // instead of the corner badge used on the small audio circle.
            Positioned(
              left: 0,
              right: 0,
              bottom: isVideo ? 8.h : 4.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDuration(state.durationSeconds),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 3),
                      ],
                    ),
                  ),
                  if (isVideo) ...[
                    SizedBox(height: 4.h),
                    _EndCallBadge(onTap: onEndCall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EndCallBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _EndCallBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22.w,
        height: 22.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.red,
          border: Border.all(color: AppColors.white, width: 1.5),
        ),
        child: Icon(Icons.call_end, color: AppColors.white, size: 12.sp),
      ),
    );
  }
}
