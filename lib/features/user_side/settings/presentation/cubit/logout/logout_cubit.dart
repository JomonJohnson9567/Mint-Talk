import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';

@injectable
class LogoutCubit extends Cubit<LogoutState> {
  final LogoutUseCase _logoutUseCase;

  LogoutCubit(this._logoutUseCase) : super(const LogoutState());

  Future<void> logout() async {
    if (state.status == LogoutStatus.loading) return;

    emit(
      state.copyWith(status: LogoutStatus.loading, errorMessage: () => null),
    );

    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LogoutStatus.failure,
          errorMessage: () => _mapFailureMessage(failure),
        ),
      ),
      (_) => emit(state.copyWith(status: LogoutStatus.success)),
    );
  }

  String _mapFailureMessage(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return 'Session expired. Please login again.';
    }
    if (failure is NetworkFailure) {
      return failure.message;
    }
    return failure.message.isNotEmpty
        ? failure.message
        : 'Unable to logout right now. Please try again.';
  }
}
