import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/services/agora/i_agora_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_ended_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_profile_avatar.dart';

class CallScreenContents extends StatelessWidget {
  final String displayName;
  final String callType;
  final bool isHost;

  const CallScreenContents({
    super.key,
    required this.displayName,
    this.callType = 'audio',
    this.isHost = false,
  });

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallScreenCubit, CallScreenState>(
      listener: (context, state) {
        if (state.isCallEnded) {
          if (state.durationSeconds > 0 ||
              state.status == CallScreenStatus.insufficientBalance) {
            _showCallSummaryDialog(context, state);
          } else {
            Navigator.of(context).maybePop();
          }
        }
      },
      builder: (context, state) {
        final cubit = context.read<CallScreenCubit>();
        final isVideo =
            (state.session?.callType ?? callType).toLowerCase() == 'video';
        final agoraEngine = getIt<IAgoraService>().engine;

        return SafeArea(
          child: Stack(
            children: [
              // If video call and remote user joined, render Agora Remote Video Stream
              if (isVideo &&
                  state.isRemoteUserJoined &&
                  state.remoteUid != null &&
                  agoraEngine != null)
                Positioned.fill(
                  child: AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: agoraEngine,
                      canvas: VideoCanvas(uid: state.remoteUid),
                      connection: RtcConnection(
                        channelId: state.session?.agoraChannel,
                      ),
                    ),
                  ),
                ),

              // Overlay UI
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Avatar
                    if (!isVideo || !state.isRemoteUserJoined)
                      CallProfileAvatar(
                        imagePath: AppAssets.maleIcon,
                        isBreathingExpanded: state.status == CallScreenStatus.ringing,
                      ),

                    SizedBox(height: 24.h),

                    // Display Name
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isVideo && state.isRemoteUserJoined
                            ? Colors.white
                            : AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // Status / Timer Label
                    Text(
                      state.status == CallScreenStatus.active
                          ? _formatDuration(state.durationSeconds)
                          : state.status == CallScreenStatus.ringing
                              ? 'Ringing...'
                              : state.status == CallScreenStatus.connecting
                                  ? 'Connecting media...'
                                  : state.status == CallScreenStatus.initiating
                                      ? 'Calling...'
                                      : state.status == CallScreenStatus.ended
                                          ? 'Call Ended'
                                          : 'Connecting...',
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
                    if (state.isCallEnded)
                      CallEndedControls(
                        onCancel: () => Navigator.pop(context),
                        onCallAgain: () => Navigator.pop(context),
                      )
                    else
                      CallControls(
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
                  ],
                ),
              ),

              // Local Camera Preview Thumbnail for Video Calls
              if (isVideo)
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  width: 100.w,
                  height: 140.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: state.isVideoMuted
                        ? Container(
                            color: Colors.black87,
                            child: Center(
                              child: Icon(
                                Icons.videocam_off,
                                color: Colors.white70,
                                size: 28.sp,
                              ),
                            ),
                          )
                        : agoraEngine != null
                            ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: agoraEngine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              )
                            : Container(
                                color: Colors.black87,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCallSummaryDialog(BuildContext context, CallScreenState state) {
    final session = state.session;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            state.status == CallScreenStatus.insufficientBalance
                ? 'Insufficient Balance'
                : 'Call Summary',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session != null) ...[
                ListTile(
                  title: const Text('Duration'),
                  trailing: Text(
                    '${session.duration} sec',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: const Text('Billed Minutes'),
                  trailing: Text(
                    '${session.billedMinutes} min',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: const Text('Points Debited'),
                  trailing: Text(
                    '${session.totalPointsDebited} pts',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ] else
                Text(state.errorMessage.isNotEmpty
                    ? state.errorMessage
                    : 'Call has ended.'),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
