import 'dart:async';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/call_background/i_call_background_service.dart';

import 'call_screen_cubit.dart';

/// Mirrors [CallScreenState] into the system call UI — the ongoing-call
/// notification (foreground service) and picture-in-picture — so a call
/// keeps running and stays visible while the app is in the background.
///
/// [sync] runs on every cubit state change; only real changes to what the
/// notification shows cross the platform channel.
class CallBackgroundSync {
  final ICallBackgroundService _service;
  final DateTime Function() _now;

  CallBackgroundSync(this._service, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// A failed show (typically: microphone permission not granted until
  /// the media path starts) is retried on a later state change, at most
  /// this often.
  static const Duration retryInterval = Duration(seconds: 2);

  /// What the notification should show right now — null when no call.
  OngoingCallInfo? _desired;

  /// Last info sent to (or being processed by) the platform.
  OngoingCallInfo? _shown;
  bool _inFlight = false;
  DateTime? _lastFailureAt;
  bool _pipEnabled = false;
  int? _activeSinceEpochMs;

  /// Tick jitter tolerated before the notification timer is re-based.
  static const int _maxTimerDriftMs = 2000;

  void sync(CallScreenState s) {
    if (!_service.isSupported) return;
    final inCall = s.status != CallScreenStatus.initial && !s.isCallEnded;
    if (!inCall) {
      stop();
      return;
    }

    _setPipEnabled(s.isPipEligible);

    if (s.isCallActive) {
      // Back-dated by the already-counted duration, and kept stable so
      // per-second ticks never re-send — but re-synced if the in-app timer
      // is corrected (e.g. server activeAt arrives late), so the
      // notification never disagrees with the call screen.
      final base = _now().millisecondsSinceEpoch - s.durationSeconds * 1000;
      final current = _activeSinceEpochMs;
      if (current == null || (base - current).abs() > _maxTimerDriftMs) {
        _activeSinceEpochMs = base;
      }
    }

    final info = OngoingCallInfo(
      displayName: s.displayName,
      avatarUrl: s.avatarUrl,
      isVideo: (s.session?.callType ?? s.callType)?.isVideo ?? false,
      isMuted: s.isMuted,
      isVideoMuted: s.isVideoMuted,
      statusText: _statusText(s),
      chronometerBaseEpochMs: s.isCallActive ? _activeSinceEpochMs : null,
    );
    _desired = info;
    _flush();
  }

  void _flush() {
    final info = _desired;
    if (_inFlight || info == null || info == _shown) return;
    final lastFailure = _lastFailureAt;
    if (lastFailure != null && _now().difference(lastFailure) < retryInterval) {
      return;
    }
    _shown = info;
    _inFlight = true;
    unawaited(
      _service.showOngoingCall(info).then((shown) {
        _inFlight = false;
        if (!shown) {
          if (identical(_shown, info)) _shown = null;
          // Not after stop() — the next call must not start throttled.
          if (_desired != null) _lastFailureAt = _now();
          return;
        }
        _lastFailureAt = null;
        // Something changed while this was in flight.
        _flush();
      }),
    );
  }

  /// Removes the notification and PiP. Safe to call repeatedly.
  void stop() {
    if (!_service.isSupported) return;
    _setPipEnabled(false);
    _activeSinceEpochMs = null;
    _desired = null;
    _lastFailureAt = null;
    if (_shown == null && !_inFlight) return;
    _shown = null;
    unawaited(_service.hideOngoingCall());
  }

  void _setPipEnabled(bool enabled) {
    if (_pipEnabled == enabled) return;
    _pipEnabled = enabled;
    unawaited(_service.setPipEnabled(enabled));
  }

  static String _statusText(CallScreenState s) {
    final isVideo = (s.session?.callType ?? s.callType)?.isVideo ?? false;
    switch (s.status) {
      case CallScreenStatus.initiating:
      case CallScreenStatus.ringing:
        return s.isHost
            ? AppTexts.connectingEllipsis
            : AppTexts.ringingEllipsis;
      case CallScreenStatus.connecting:
        return AppTexts.connectingEllipsis;
      case CallScreenStatus.active:
        if (s.networkStatus.isLocalDeviceOffline) return AppTexts.youAreOffline;
        if (s.networkStatus.isRemoteReconnecting ||
            s.mediaStatus == CallMediaStatus.reconnecting) {
          return AppTexts.reconnectingEllipsis;
        }
        return isVideo ? AppTexts.ongoingVideoCall : AppTexts.ongoingVoiceCall;
      case CallScreenStatus.initial:
      case CallScreenStatus.ended:
      case CallScreenStatus.insufficientBalance:
      case CallScreenStatus.failed:
        return '';
    }
  }
}
