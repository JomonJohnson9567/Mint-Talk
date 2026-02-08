import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({Duration delay = const Duration(seconds: 2)})
      : _delay = delay,
        super(const SplashState()) {
    _startTimer();
  }

  final Duration _delay;

  void _startTimer() {
    Future.delayed(_delay, () {
      if (isClosed) return;
      emit(state.copyWith(shouldNavigate: true));
    });
  }
}
