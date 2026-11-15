import 'package:equatable/equatable.dart';

enum IncomingCallActionType { answer, decline, open }

/// What the host tapped on the incoming-call notification.
class IncomingCallAction extends Equatable {
  final IncomingCallActionType type;
  final String callId;

  const IncomingCallAction(this.type, this.callId);

  @override
  List<Object?> get props => [type, callId];
}

/// What the incoming-call notification shows.
class IncomingCallAlert extends Equatable {
  final String callId;
  final String callerName;
  final String? avatarUrl;
  final bool isVideo;

  /// Ring time left; the notification also removes itself after this.
  final Duration timeout;

  const IncomingCallAlert({
    required this.callId,
    required this.callerName,
    required this.isVideo,
    required this.timeout,
    this.avatarUrl,
  });

  Map<String, Object?> toMap() => {
    'callId': callId,
    'callerName': callerName,
    'avatarUrl': avatarUrl,
    'isVideo': isVideo,
    'timeoutMs': timeout.inMilliseconds,
  };

  @override
  List<Object?> get props => [callId, callerName, avatarUrl, isVideo, timeout];
}

/// Keeps an online host reachable while the app is minimized, and rings
/// them through the system notification shade.
///
/// Android: the host-standby mode of the app's foreground service (stops
/// the OS from freezing the process, so the presence socket stays up) and
/// a call-style incoming-call notification with Answer / Decline and a
/// full-screen intent. Other platforms: no-op ([isSupported] is false).
///
/// Nothing here throws: a failure only means the system UI is missing.
abstract interface class IIncomingCallAlertService {
  bool get isSupported;

  /// Host went online. Call while the app is in the foreground — Android
  /// refuses to start the service from the background. Returns false when
  /// it couldn't start.
  Future<bool> startHostStandby({required bool audio, required bool video});

  /// Host went offline. A running call keeps its own notification.
  Future<void> stopHostStandby();

  Future<bool> showIncomingCall(IncomingCallAlert alert);

  Future<void> hideIncomingCall();

  /// Stops showing the app above the lock screen — set natively when the
  /// incoming-call notification brought the app forward.
  Future<void> clearLockScreenOverride();

  /// Answer / Decline / tap on the incoming-call notification.
  Stream<IncomingCallAction> get actions;
}
