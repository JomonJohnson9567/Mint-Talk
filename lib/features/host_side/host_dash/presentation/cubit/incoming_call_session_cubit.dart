import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/services/audio/incoming_ringer_service.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/reject_call_usecase.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/ring_window.dart';

class IncomingCallSessionState extends Equatable {
  final bool isProcessing;
  final bool isAvatarExpanded;
  final double ringPhase;

  const IncomingCallSessionState({
    this.isProcessing = false,
    this.isAvatarExpanded = false,
    this.ringPhase = 0.0,
  });

  IncomingCallSessionState copyWith({
    bool? isProcessing,
    bool? isAvatarExpanded,
    double? ringPhase,
  }) {
    return IncomingCallSessionState(
      isProcessing: isProcessing ?? this.isProcessing,
      isAvatarExpanded: isAvatarExpanded ?? this.isAvatarExpanded,
      ringPhase: ringPhase ?? this.ringPhase,
    );
  }

  @override
  List<Object?> get props => [isProcessing, isAvatarExpanded, ringPhase];
}

/// Owns one incoming-call dialog's lifetime: the breathing-avatar toggle,
/// the ring-pulse phase, the call-status subscription that auto-dismisses
/// on missed/ended/rejected/cancelled, accept/reject, and the looping
/// ringtone (the same tone the caller hears, following the device's
/// ringer mode and Do Not Disturb), which plays from creation
/// until the call is accepted, rejected, auto-dismissed or the cubit closes.
///
/// Created fresh per dialog instance (not DI-registered) and closed when
/// the dialog is dismissed.
class IncomingCallSessionCubit extends Cubit<IncomingCallSessionState> {
  final IncomingCallPayloadDto payload;
  final VoidCallback onDismiss;
  final IPresenceSocketService _presenceSocketService;
  final RejectCallUseCase _rejectCallUseCase;
  final IIncomingRingerService _ringtone;

  StreamSubscription<Map<String, dynamic>>? _statusSub;
  Timer? _breathingTimer;
  Timer? _ringTimer;

  /// Closes the overlay at the payload's server `ringExpiresAt` (audio and
  /// video alike); [ringTimeout] is only the fallback when it's missing.
  /// The server misses the call / the caller cancels on the same deadline,
  /// so this is not a reject.
  Timer? _noAnswerTimer;
  @visibleForTesting
  static Duration ringTimeout = RingWindow.fallback;

  /// Server-corrected "now" (`ServerClock.now`) for [RingWindow].
  final DateTime Function() _serverNow;

  /// True once the call has been handed off to [CallScreen], which owns
  /// the call's socket subscription from that point on — prevents
  /// `close()` from unsubscribing a channel the new screen just
  /// subscribed to.
  bool _handedOffToCallScreen = false;

  static const _ringCycle = Duration(milliseconds: 2200);

  /// Any of these (from `call_missed`, `call_cancelled`, … or a terminal
  /// `call_status_update`) closes the still-ringing overlay.
  static const _terminalStatuses = {
    'missed',
    'ended',
    'rejected',
    'cancelled',
    'failed',
    'insufficient_balance',
  };

  IncomingCallSessionCubit({
    required this.payload,
    required this.onDismiss,
    required IPresenceSocketService presenceSocketService,
    required RejectCallUseCase rejectCallUseCase,
    required IIncomingRingerService ringtone,
    DateTime Function()? serverNow,
  }) : _presenceSocketService = presenceSocketService,
       _serverNow = serverNow ?? DateTime.now,
       _rejectCallUseCase = rejectCallUseCase,
       _ringtone = ringtone,
       super(const IncomingCallSessionState()) {
    _listenForStatusUpdates();
    unawaited(_ringtone.start());
    _noAnswerTimer = Timer(
      RingWindow.remaining(
        payload.ringExpiresAt,
        _serverNow(),
        fallback: ringTimeout,
      ),
      _dismissUnanswered,
    );

    _breathingTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (isClosed) return;
      emit(state.copyWith(isAvatarExpanded: !state.isAvatarExpanded));
    });

    // Drives the expanding-ring pulse. A raw AnimationController+vsync
    // would be smoother (paints without rebuilding), but that requires a
    // TickerProvider tied to widget State — this ~20 ticks/sec timer is a
    // deliberate trade-off to keep the widget stateless, isolated behind
    // its own BlocBuilder so nothing else on this dialog rebuilds per tick.
    final stopwatch = Stopwatch()..start();
    _ringTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (isClosed) return;
      final phase =
          (stopwatch.elapsedMilliseconds % _ringCycle.inMilliseconds) /
          _ringCycle.inMilliseconds;
      emit(state.copyWith(ringPhase: phase));
    });
  }

  void _listenForStatusUpdates() {
    _presenceSocketService.subscribeCall(payload.callId);
    _statusSub = _presenceSocketService.callStatusUpdates.listen((data) {
      // callStatusUpdates is one shared, app-wide stream, not scoped to
      // this call — without this check, a stray terminal event belonging to
      // a different call (e.g. a delayed push from a call that just ended
      // elsewhere) would auto-dismiss this still-ringing overlay as if it
      // had been missed/ended/rejected/cancelled itself.
      final eventCallId = (data['callId'] ?? data['id'] ?? data['_id'])
          ?.toString();
      if (eventCallId != null &&
          eventCallId.isNotEmpty &&
          eventCallId != payload.callId) {
        return;
      }

      final status = data['status']?.toString();
      final isTerminal = _terminalStatuses.contains(status);
      if (!isTerminal || isClosed || state.isProcessing) return;
      _noAnswerTimer?.cancel();
      unawaited(_ringtone.stop());
      emit(state.copyWith(isProcessing: true));
      onDismiss();
    });
  }

  /// Ring limit reached with no answer — close the overlay locally. The
  /// caller's /cancel ends the call on the server; a `call_cancelled` push
  /// arriving afterwards is ignored by the `isProcessing` guard above.
  void _dismissUnanswered() {
    _noAnswerTimer = null;
    if (isClosed || state.isProcessing) return;
    unawaited(_ringtone.stop());
    emit(state.copyWith(isProcessing: true));
    onDismiss();
  }

  /// Stops the ring/breathing timers immediately — called the instant
  /// Accept is tapped. The HTTP accept call now happens inside
  /// `CallScreenCubit.acceptIncomingCall` after `CallScreen` is already on
  /// screen (see [IncomingCallOverlayListener]'s `_handleAccept`), not
  /// here, so the dialog never blocks on the network round trip.
  ///
  /// Deliberately does NOT call [onDismiss] (unlike [reject] and the
  /// terminal-status path below): `_handleAccept` already replaces this
  /// dialog's route with `CallScreen` via `pushReplacement`, so popping
  /// here too would remove the just-pushed `CallScreen` instead.
  void handOffToCallScreen() {
    if (state.isProcessing) return;
    _noAnswerTimer?.cancel();
    _breathingTimer?.cancel();
    _ringTimer?.cancel();
    // Stop before CallScreen's Agora join takes over the audio session.
    unawaited(_ringtone.stop());
    _handedOffToCallScreen = true;
    emit(state.copyWith(isProcessing: true));
  }

  Future<void> reject() async {
    if (state.isProcessing) return;
    _noAnswerTimer?.cancel();
    emit(state.copyWith(isProcessing: true));
    unawaited(_ringtone.stop());
    await _rejectCallUseCase(payload.callId);
    onDismiss();
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    _noAnswerTimer?.cancel();
    _breathingTimer?.cancel();
    _ringTimer?.cancel();
    unawaited(_ringtone.stop());
    if (!_handedOffToCallScreen) {
      _presenceSocketService.unsubscribeCall(payload.callId);
    }
    return super.close();
  }
}
