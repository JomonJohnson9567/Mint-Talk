import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/services/audio/incoming_ringer_service.dart';
import 'package:mint_talk/core/services/incoming_call_alert/i_incoming_call_alert_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/ring_window.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/reject_call_usecase.dart';

import 'incoming_call_overlay_state.dart';

/// Owns "a call is ringing for this host" for the whole time the host nav
/// shell is mounted, in the foreground and while the app is minimized.
///
/// - Foreground: each `incoming_call` socket event becomes a
///   [IncomingCallOverlayState.showRequest]; the widget shows the
///   full-screen ringing dialog, whose `IncomingCallSessionCubit` rings,
///   times out and watches the call from there.
/// - Background (Home / app switch): Flutter draws no frames, so that
///   dialog — and its ringer — would never start. Instead this cubit rings
///   ([IIncomingRingerService]), shows the system incoming-call
///   notification ([IIncomingCallAlertService]) and watches the call itself
///   until the host comes back (the dialog takes over), answers or declines
///   from the notification, or the call ends / the ring window closes.
///
/// Only one call rings at a time; a second `incoming_call` meanwhile is
/// ignored, as before.
class IncomingCallOverlayCubit extends Cubit<IncomingCallOverlayState> {
  final IPresenceSocketService _presenceSocketService;
  final IIncomingCallAlertService _alertService;
  final IIncomingRingerService _ringtone;
  final RejectCallUseCase _rejectCallUseCase;

  /// Server-corrected "now" (`ServerClock.now`) for [RingWindow].
  final DateTime Function() _serverNow;

  StreamSubscription<Map<String, dynamic>>? _incomingCallSub;
  StreamSubscription<IncomingCallAction>? _actionSub;
  StreamSubscription<AppLifecycleState>? _lifecycleSub;
  AppLifecycleListener? _lifecycleListener;

  /// The ringing call — waiting in the background or on screen — or null.
  IncomingCallPayloadDto? _current;
  bool _isDialogShowing = false;
  bool _accepted = false;
  bool _isForeground;
  bool _isAlertShown = false;

  /// Background ringing only, until the dialog takes over.
  Timer? _backgroundRingTimer;
  StreamSubscription<Map<String, dynamic>>? _backgroundStatusSub;

  /// Same set as `IncomingCallSessionCubit` — any of these ends the ringing.
  static const _terminalStatuses = {
    'missed',
    'ended',
    'rejected',
    'cancelled',
    'failed',
    'insufficient_balance',
  };

  /// [lifecycleChanges] / [initialLifecycleState] are for tests; by default
  /// the app's real lifecycle is followed.
  IncomingCallOverlayCubit({
    required IPresenceSocketService presenceSocketService,
    required IIncomingCallAlertService incomingCallAlertService,
    required IIncomingRingerService ringtone,
    required RejectCallUseCase rejectCallUseCase,
    DateTime Function()? serverNow,
    Stream<AppLifecycleState>? lifecycleChanges,
    AppLifecycleState? initialLifecycleState,
  }) : _presenceSocketService = presenceSocketService,
       _alertService = incomingCallAlertService,
       _ringtone = ringtone,
       _rejectCallUseCase = rejectCallUseCase,
       _serverNow = serverNow ?? DateTime.now,
       _isForeground = _isForegroundState(
         lifecycleChanges == null
             ? WidgetsBinding.instance.lifecycleState
             : initialLifecycleState,
       ),
       super(const IncomingCallOverlayState()) {
    _incomingCallSub = presenceSocketService.incomingCalls.listen(
      _onIncomingCall,
    );
    _actionSub = incomingCallAlertService.actions.listen(_onAlertAction);
    if (lifecycleChanges != null) {
      _lifecycleSub = lifecycleChanges.listen(_onLifecycleChanged);
    } else {
      _lifecycleListener = AppLifecycleListener(
        onStateChange: _onLifecycleChanged,
      );
    }
  }

  /// `inactive` is still on screen (notification shade, app-switch start);
  /// null means the lifecycle isn't known yet — the app is starting up.
  static bool _isForegroundState(AppLifecycleState? state) =>
      state == null ||
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;

  // ---------------------------------------------------------------------------
  // Incoming calls
  // ---------------------------------------------------------------------------

  void _onIncomingCall(Map<String, dynamic> data) {
    if (isClosed || _current != null) return;
    final payload = IncomingCallPayloadDto.fromJson(data);
    if (payload.callId.isEmpty) return;
    if (_isForeground) {
      _current = payload;
      _showRingingScreen();
    } else {
      _ringInBackground(payload);
    }
  }

  void _ringInBackground(IncomingCallPayloadDto payload) {
    final now = _serverNow();
    final left = RingWindow.remaining(payload.ringExpiresAt, now);
    // Delivered after the ring window closed (e.g. the socket woke late).
    if (left == Duration.zero) return;

    // Pin the deadline, so the dialog shown later (fallback window when the
    // server sent none) closes at the same moment rather than restarting it.
    final pinned = payload.copyWith(ringExpiresAt: now.add(left));
    _current = pinned;

    _presenceSocketService.subscribeCall(pinned.callId);
    _backgroundStatusSub = _presenceSocketService.callStatusUpdates.listen((
      data,
    ) {
      if (_isTerminalFor(data, pinned.callId)) _endBackgroundRing();
    });
    _backgroundRingTimer = Timer(left, _endBackgroundRing);
    unawaited(_ringtone.start());
    _showAlert(pinned, left);
  }

  /// `callStatusUpdates` is one app-wide stream — only this call's terminal
  /// events count (an event without a call id is taken as this call's,
  /// like `IncomingCallSessionCubit` does).
  bool _isTerminalFor(Map<String, dynamic> data, String callId) {
    final eventCallId = (data['callId'] ?? data['id'] ?? data['_id'])
        ?.toString();
    if (eventCallId != null &&
        eventCallId.isNotEmpty &&
        eventCallId != callId) {
      return false;
    }
    return _terminalStatuses.contains(data['status']?.toString());
  }

  /// The call ended, the ring window closed, or the host declined — all
  /// while no dialog is up yet.
  void _endBackgroundRing() {
    _stopBackgroundWatch();
    final current = _current;
    if (current == null || _isDialogShowing) return;
    _current = null;
    unawaited(_ringtone.stop());
    _hideAlert();
    _presenceSocketService.unsubscribeCall(current.callId);
    // A full-screen launch may have put the app above the lock screen.
    unawaited(_alertService.clearLockScreenOverride());
  }

  void _stopBackgroundWatch() {
    _backgroundRingTimer?.cancel();
    _backgroundRingTimer = null;
    _backgroundStatusSub?.cancel();
    _backgroundStatusSub = null;
  }

  /// Hands the ringing call to the dialog. From here its
  /// `IncomingCallSessionCubit` owns the ringer (its `start()` is a no-op
  /// while already ringing), the call subscription and the ring window.
  void _showRingingScreen({bool autoAccept = false}) {
    final current = _current;
    if (isClosed || current == null) return;
    _stopBackgroundWatch();
    _isDialogShowing = true;
    _accepted = false;
    if (_isForeground || autoAccept) _hideAlert();
    emit(
      IncomingCallOverlayState(
        payload: current,
        showRequest: state.showRequest + 1,
        autoAccept: autoAccept,
        commandRequest: state.commandRequest,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App lifecycle
  // ---------------------------------------------------------------------------

  void _onLifecycleChanged(AppLifecycleState lifecycleState) {
    final isForeground = _isForegroundState(lifecycleState);
    if (isForeground == _isForeground) return;
    _isForeground = isForeground;
    final current = _current;
    if (isClosed || current == null) return;

    if (isForeground) {
      // Back in the app: the in-app ringing screen replaces the notification.
      _hideAlert();
      if (!_isDialogShowing) _showRingingScreen();
    } else if (_isDialogShowing && !_accepted) {
      // Left the app while the ringing screen was up — keep it reachable.
      final left = RingWindow.remaining(current.ringExpiresAt, _serverNow());
      if (left > Duration.zero) _showAlert(current, left);
    }
  }

  // ---------------------------------------------------------------------------
  // Notification actions
  // ---------------------------------------------------------------------------

  void _onAlertAction(IncomingCallAction action) {
    if (isClosed) return;
    final current = _current;
    if (current == null) {
      // A stale notification for a call that's already over; its tap may
      // have put the app above the lock screen.
      if (action.type != IncomingCallActionType.decline) {
        unawaited(_alertService.clearLockScreenOverride());
      }
      return;
    }
    if (action.callId != current.callId) return;

    switch (action.type) {
      case IncomingCallActionType.answer:
        _hideAlert();
        if (_isDialogShowing) {
          _sendCommand(IncomingCallCommand.accept);
        } else {
          _showRingingScreen(autoAccept: true);
        }
      case IncomingCallActionType.decline:
        _hideAlert();
        if (_isDialogShowing) {
          _sendCommand(IncomingCallCommand.decline);
        } else {
          _endBackgroundRing();
          unawaited(_rejectCallUseCase(current.callId));
        }
      case IncomingCallActionType.open:
        // The app is coming to the foreground; the resume shows the dialog.
        break;
    }
  }

  void _sendCommand(IncomingCallCommand command) {
    emit(
      IncomingCallOverlayState(
        payload: state.payload,
        showRequest: state.showRequest,
        command: command,
        commandRequest: state.commandRequest + 1,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialog callbacks
  // ---------------------------------------------------------------------------

  /// The host accepted on the ringing screen; the call screen takes over.
  void callAccepted() {
    _accepted = true;
    _hideAlert();
  }

  /// Called by the widget once the incoming-call dialog is gone (accepted,
  /// rejected, or auto-dismissed), so the next incoming call can show.
  void dialogDismissed() {
    final accepted = _accepted;
    _isDialogShowing = false;
    _accepted = false;
    _current = null;
    _stopBackgroundWatch();
    _hideAlert();
    // An accepted call clears it itself when it ends (ongoing-call hide).
    if (!accepted) unawaited(_alertService.clearLockScreenOverride());
  }

  // ---------------------------------------------------------------------------
  // Notification helpers
  // ---------------------------------------------------------------------------

  void _showAlert(IncomingCallPayloadDto payload, Duration left) {
    _isAlertShown = true;
    unawaited(
      _alertService.showIncomingCall(
        IncomingCallAlert(
          callId: payload.callId,
          callerName: payload.callerName,
          avatarUrl: payload.callerAvatar,
          isVideo: payload.callType.isVideo,
          timeout: left,
        ),
      ),
    );
  }

  void _hideAlert() {
    if (!_isAlertShown) return;
    _isAlertShown = false;
    unawaited(_alertService.hideIncomingCall());
  }

  @override
  Future<void> close() {
    _incomingCallSub?.cancel();
    _actionSub?.cancel();
    _lifecycleSub?.cancel();
    _lifecycleListener?.dispose();
    if (!_isDialogShowing) _endBackgroundRing();
    _stopBackgroundWatch();
    _hideAlert();
    return super.close();
  }
}
