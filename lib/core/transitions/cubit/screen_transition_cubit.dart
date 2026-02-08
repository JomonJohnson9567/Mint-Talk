import 'package:flutter_bloc/flutter_bloc.dart';
import 'screen_transition_state.dart';

class ScreenTransitionCubit extends Cubit<ScreenTransitionState> {
  ScreenTransitionCubit() : super(const ScreenTransitionState());

  void updateContainerSlide(double progress) {
    emit(
      state.copyWith(
        phase: TransitionPhase.containerSliding,
        containerSlideProgress: progress,
      ),
    );
  }

  void updateImageFade(double progress) {
    emit(state.copyWith(imageFadeProgress: progress));
  }

  void updateContainerMorph(double progress) {
    emit(
      state.copyWith(
        phase: TransitionPhase.containerMorphing,
        containerMorphProgress: progress,
      ),
    );
  }

  void updateContentFade(double progress) {
    emit(
      state.copyWith(
        phase: TransitionPhase.contentFading,
        contentFadeProgress: progress,
      ),
    );
  }

  void setReverse(bool isReverse) {
    emit(state.copyWith(isReverse: isReverse));
  }

  void complete() {
    emit(state.copyWith(phase: TransitionPhase.completed));
  }

  void reset() {
    emit(const ScreenTransitionState());
  }
}
