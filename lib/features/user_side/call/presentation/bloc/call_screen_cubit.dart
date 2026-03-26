import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
part 'call_screen_state.dart';

@injectable
class CallScreenCubit extends Cubit<CallScreenState> {
  static const _waveTick = Duration(milliseconds: 180);
  static const _breathingTick = Duration(milliseconds: 1400);

  Timer? _waveTimer;
  Timer? _breathingTimer;

  CallScreenCubit() : super(const CallScreenState()) {
    _startOngoingAnimations();
  }

  void endCall() {
    _stopAnimations();
    emit(
      state.copyWith(
        status: CallScreenStatus.ended,
        isBreathingExpanded: false,
        waveStep: 0,
      ),
    );
  }

  void startCall() {
    _stopAnimations();
    emit(const CallScreenState(status: CallScreenStatus.ongoing));
    _startOngoingAnimations();
  }

  void _startOngoingAnimations() {
    _waveTimer = Timer.periodic(_waveTick, (_) {
      if (state.status != CallScreenStatus.ongoing) {
        return;
      }

      emit(state.copyWith(waveStep: state.waveStep + 1));
    });

    _breathingTimer = Timer.periodic(_breathingTick, (_) {
      if (state.status != CallScreenStatus.ongoing) {
        return;
      }

      emit(
        state.copyWith(isBreathingExpanded: !state.isBreathingExpanded),
      );
    });
  }

  void _stopAnimations() {
    _waveTimer?.cancel();
    _breathingTimer?.cancel();
    _waveTimer = null;
    _breathingTimer = null;
  }

  @override
  Future<void> close() {
    _stopAnimations();
    return super.close();
  }
}
