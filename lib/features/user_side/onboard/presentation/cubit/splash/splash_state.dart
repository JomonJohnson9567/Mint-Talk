part of 'splash_cubit.dart';

class SplashState extends Equatable {
  final bool shouldNavigate;

  const SplashState({this.shouldNavigate = false});

  SplashState copyWith({bool? shouldNavigate}) {
    return SplashState(shouldNavigate: shouldNavigate ?? this.shouldNavigate);
  }

  @override
  List<Object> get props => [shouldNavigate];
}
