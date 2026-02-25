import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'snack_bar_state.dart';

@injectable
class SnackBarCubit extends Cubit<SnackBarState> {
  SnackBarCubit() : super(const SnackBarState());

  void show(String message, {SnackBarType? type}) {
    emit(state.copyWith(isVisible: true, message: message, type: type));
  }

  void hide() {
    emit(state.copyWith(isVisible: false));
  }
}
