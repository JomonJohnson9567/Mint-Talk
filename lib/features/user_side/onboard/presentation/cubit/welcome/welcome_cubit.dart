import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'welcome_state.dart';

class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit() : super(const WelcomeState());

  void toggleAgreement(bool? value) {
    emit(state.copyWith(isAgreed: value ?? false));
  }
}
