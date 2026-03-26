import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'success_animation_state.dart';

class SuccessAnimationCubit extends Cubit<SuccessAnimationState> {
  SuccessAnimationCubit() : super(const SuccessAnimationState());

  /// Starts the animation loops
  void startAnimation() {
    // We can just trigger the first state change to kick off implicit animations if strictly needed,
    // or simply rely on the UI to react to the initial state and then trigger the loop.
    // However, since implicit animations engage on *change*, we should probably toggle once.
    toggleBreathing();
    loopWave();
  }

  /// Toggles the expansion state for the breathing animation
  void toggleBreathing() {
    emit(state.copyWith(isExpanded: !state.isExpanded));
  }

  /// Increments the cycle count to loop the wave animation
  void loopWave() {
    emit(state.copyWith(waveCycle: state.waveCycle + 1));
  }
}
