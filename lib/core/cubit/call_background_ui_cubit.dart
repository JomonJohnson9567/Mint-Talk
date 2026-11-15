import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/services/call_background/i_call_background_service.dart';

class CallBackgroundUiState extends Equatable {
  /// The app is shown in the floating picture-in-picture window.
  final bool isInPip;

  /// Bumped each time the user asks to get back to the call from outside
  /// the app (tapped the ongoing-call notification) — a counter, so two
  /// taps in a row are still two distinct state changes.
  final int openCallRequests;

  const CallBackgroundUiState({
    this.isInPip = false,
    this.openCallRequests = 0,
  });

  CallBackgroundUiState copyWith({bool? isInPip, int? openCallRequests}) {
    return CallBackgroundUiState(
      isInPip: isInPip ?? this.isInPip,
      openCallRequests: openCallRequests ?? this.openCallRequests,
    );
  }

  @override
  List<Object?> get props => [isInPip, openCallRequests];
}

/// UI side of [ICallBackgroundService]: whether the app is in
/// picture-in-picture (so the call screen renders its compact layout) and
/// "open the call" requests from the notification (so the minimized call
/// is restored to full screen). Call actions themselves (hang up, mute,
/// camera) are handled by `CallScreenCubit`.
@injectable
class CallBackgroundUiCubit extends Cubit<CallBackgroundUiState> {
  late final StreamSubscription<bool> _pipSub;
  late final StreamSubscription<CallBackgroundAction> _actionSub;

  CallBackgroundUiCubit(ICallBackgroundService service)
    : super(const CallBackgroundUiState()) {
    _pipSub = service.pipModeChanges.listen(
      (inPip) => emit(state.copyWith(isInPip: inPip)),
    );
    _actionSub = service.actions
        .where((action) => action == CallBackgroundAction.openCall)
        .listen(
          (_) => emit(
            state.copyWith(openCallRequests: state.openCallRequests + 1),
          ),
        );
  }

  @override
  Future<void> close() {
    _pipSub.cancel();
    _actionSub.cancel();
    return super.close();
  }
}
