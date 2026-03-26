part of 'success_animation_cubit.dart';

class SuccessAnimationState extends Equatable {
  final bool isExpanded;
  final int waveCycle;

  const SuccessAnimationState({this.isExpanded = true, this.waveCycle = 0});

  SuccessAnimationState copyWith({bool? isExpanded, int? waveCycle}) {
    return SuccessAnimationState(
      isExpanded: isExpanded ?? this.isExpanded,
      waveCycle: waveCycle ?? this.waveCycle,
    );
  }

  @override
  List<Object> get props => [isExpanded, waveCycle];
}
