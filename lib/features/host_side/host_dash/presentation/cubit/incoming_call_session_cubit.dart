import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/usecases/reject_call_usecase.dart';

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
/// on missed/ended/rejected/cancelled, and accept/reject.
///
/// Created fresh per dialog instance (not DI-registered) and closed when
/// the dialog is dismissed.
class IncomingCallSessionCubit extends Cubit<IncomingCallSessionState> {
  final IncomingCallPayloadDto payload;
  final VoidCallback onDismiss;
  final IPresenceSocketService _presenceSocketService;
  final RejectCallUseCase _rejectCallUseCase;

  StreamSubscription<Map<String, dynamic>>? _statusSub;
  Timer? _breathingTimer;
  Timer? _ringTimer;

  /// True once the call has been handed off to [CallScreen], which owns
  /// the call's socket subscription from that point on — prevents
  /// `close()` from unsubscribing a channel the new screen just
  /// subscribed to.
  bool _handedOffToCallScreen = false;

  static const _ringCycle = Duration(milliseconds: 2200);

  IncomingCallSessionCubit({
    required this.payload,
    required this.onDismiss,
    required IPresenceSocketService presenceSocketService,
    required RejectCallUseCase rejectCallUseCase,
  })  : _presenceSocketService = presenceSocketService,
        _rejectCallUseCase = rejectCallUseCase,
        super(const IncomingCallSessionState()) {
    _listenForStatusUpdates();

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
      final status = data['status']?.toString();
      final isTerminal =
          status == 'missed' ||
          status == 'ended' ||
          status == 'rejected' ||
          status == 'cancelled';
      if (!isTerminal || isClosed || state.isProcessing) return;
      emit(state.copyWith(isProcessing: true));
      onDismiss();
    });
  }

  /// Stops the ring/breathing timers and dismisses the dialog immediately —
  /// called the instant Accept is tapped. The HTTP accept call now happens
  /// inside `CallScreenCubit.acceptIncomingCall` after `CallScreen` is
  /// already on screen (see [IncomingCallOverlayListener]'s `_handleAccept`),
  /// not here, so the dialog never blocks on the network round trip.
  void handOffToCallScreen() {
    if (state.isProcessing) return;
    _breathingTimer?.cancel();
    _ringTimer?.cancel();
    _handedOffToCallScreen = true;
    emit(state.copyWith(isProcessing: true));
    onDismiss();
  }

  Future<void> reject() async {
    if (state.isProcessing) return;
    emit(state.copyWith(isProcessing: true));
    await _rejectCallUseCase(payload.callId);
    onDismiss();
  }

  @override
  Future<void> close() {
    _statusSub?.cancel();
    _breathingTimer?.cancel();
    _ringTimer?.cancel();
    if (!_handedOffToCallScreen) {
      _presenceSocketService.unsubscribeCall(payload.callId);
    }
    return super.close();
  }
}
