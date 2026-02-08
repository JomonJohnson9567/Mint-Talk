part of 'welcome_cubit.dart';

class WelcomeState extends Equatable {
  final bool isAgreed;

  const WelcomeState({this.isAgreed = false});

  WelcomeState copyWith({bool? isAgreed}) {
    return WelcomeState(isAgreed: isAgreed ?? this.isAgreed);
  }

  @override
  List<Object> get props => [isAgreed];
}
