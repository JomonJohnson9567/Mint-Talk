import 'package:equatable/equatable.dart';

/// What the user tapped on the ongoing-call notification or a
/// picture-in-picture action.
enum CallBackgroundAction { hangUp, toggleMute, toggleCamera, openCall }

/// Everything the system call UI (ongoing-call notification, PiP actions)
/// shows. Equality drives re-sends: only a real change crosses the
/// platform channel, never a per-second duration tick — the notification
/// runs its own chronometer from [chronometerBaseEpochMs].
class OngoingCallInfo extends Equatable {
  final String displayName;
  final String? avatarUrl;
  final bool isVideo;
  final bool isMuted;
  final bool isVideoMuted;

  /// Notification body, e.g. "Ringing…", "Reconnecting…".
  final String statusText;

  /// Wall-clock moment the call went active — the notification counts up
  /// from here. Null until then (no timer while ringing/connecting).
  final int? chronometerBaseEpochMs;

  const OngoingCallInfo({
    required this.displayName,
    required this.isVideo,
    required this.isMuted,
    required this.isVideoMuted,
    required this.statusText,
    this.avatarUrl,
    this.chronometerBaseEpochMs,
  });

  Map<String, Object?> toMap() => {
    'displayName': displayName,
    'avatarUrl': avatarUrl,
    'isVideo': isVideo,
    'isMuted': isMuted,
    'isVideoMuted': isVideoMuted,
    'statusText': statusText,
    'chronometerBaseEpochMs': chronometerBaseEpochMs,
  };

  @override
  List<Object?> get props => [
    displayName,
    avatarUrl,
    isVideo,
    isMuted,
    isVideoMuted,
    statusText,
    chronometerBaseEpochMs,
  ];
}

/// Keeps a call alive and visible while the app is in the background.
///
/// Android: a microphone/camera foreground service with a call-style
/// ongoing notification, plus native picture-in-picture for video calls.
/// Other platforms: no-op ([isSupported] is false) — iOS keeps the call
/// alive through its `audio`/`voip` background modes instead.
///
/// Nothing here throws: a failure only means the system UI is missing,
/// which must never break the call itself.
abstract interface class ICallBackgroundService {
  bool get isSupported;

  /// Starts the foreground service on first call, updates its notification
  /// afterwards. Returns false when it couldn't be shown (e.g. microphone
  /// permission not granted yet) so the caller can retry later.
  Future<bool> showOngoingCall(OngoingCallInfo info);

  /// Stops the foreground service and removes the notification. Also
  /// leaves picture-in-picture if the app is in it.
  Future<void> hideOngoingCall();

  /// While enabled, leaving the app (Home / app switch) shrinks it into a
  /// floating picture-in-picture window instead of hiding it.
  Future<void> setPipEnabled(bool enabled);

  /// True while the app is shown in the picture-in-picture window.
  Stream<bool> get pipModeChanges;

  Stream<CallBackgroundAction> get actions;
}
