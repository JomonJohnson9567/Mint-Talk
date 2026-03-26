part of 'call_screen_cubit.dart';

enum CallScreenStatus { ongoing, ended }

final class CallScreenState extends Equatable {
  final CallScreenStatus status;
  final bool isBreathingExpanded;
  final int waveStep;

  const CallScreenState({
    this.status = CallScreenStatus.ongoing,
    this.isBreathingExpanded = true,
    this.waveStep = 0,
  });

  bool get isCallEnded => status == CallScreenStatus.ended;

  CallScreenState copyWith({
    CallScreenStatus? status,
    bool? isBreathingExpanded,
    int? waveStep,
  }) {
    return CallScreenState(
      status: status ?? this.status,
      isBreathingExpanded: isBreathingExpanded ?? this.isBreathingExpanded,
      waveStep: waveStep ?? this.waveStep,
    );
  }

  @override
  List<Object> get props => [status, isBreathingExpanded, waveStep];
}
