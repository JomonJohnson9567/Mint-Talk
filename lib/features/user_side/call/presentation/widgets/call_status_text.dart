import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

String formatCallDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Network conditions take priority and render regardless of the
/// top-level [CallScreenStatus] — a mid-call blip (the common case) still
/// happens while `status == active`, not just during the initial join.
String callStatusLabel(CallScreenState state) {
  if (state.isNoAnswer) {
    return 'No answer';
  }
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
      ? formatCallDuration(state.durationSeconds)
      : state.status == CallScreenStatus.ringing
      ? 'Ringing...'
      : state.status == CallScreenStatus.connecting &&
            state.isAwaitingPeerActivation
      ? 'Connecting...'
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
