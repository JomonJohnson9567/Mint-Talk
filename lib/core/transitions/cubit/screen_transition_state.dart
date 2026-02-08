import 'package:equatable/equatable.dart';

enum TransitionPhase {
  initial,
  containerSliding,
  containerMorphing,
  contentFading,
  completed,
}

class ScreenTransitionState extends Equatable {
  final TransitionPhase phase;
  final double containerSlideProgress;
  final double imageFadeProgress;
  final double containerMorphProgress;
  final double contentFadeProgress;
  final bool isReverse;

  const ScreenTransitionState({
    this.phase = TransitionPhase.initial,
    this.containerSlideProgress = 0.0,
    this.imageFadeProgress = 0.0,
    this.containerMorphProgress = 0.0,
    this.contentFadeProgress = 0.0,
    this.isReverse = false,
  });

  ScreenTransitionState copyWith({
    TransitionPhase? phase,
    double? containerSlideProgress,
    double? imageFadeProgress,
    double? containerMorphProgress,
    double? contentFadeProgress,
    bool? isReverse,
  }) {
    return ScreenTransitionState(
      phase: phase ?? this.phase,
      containerSlideProgress:
          containerSlideProgress ?? this.containerSlideProgress,
      imageFadeProgress: imageFadeProgress ?? this.imageFadeProgress,
      containerMorphProgress:
          containerMorphProgress ?? this.containerMorphProgress,
      contentFadeProgress: contentFadeProgress ?? this.contentFadeProgress,
      isReverse: isReverse ?? this.isReverse,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    containerSlideProgress,
    imageFadeProgress,
    containerMorphProgress,
    contentFadeProgress,
    isReverse,
  ];
}
