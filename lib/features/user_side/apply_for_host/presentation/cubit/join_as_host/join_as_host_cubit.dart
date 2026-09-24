import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../../../domain/usecases/join_as_host_usecase.dart';
import 'join_as_host_state.dart';

@injectable
class JoinAsHostCubit extends Cubit<JoinAsHostState> {
  final JoinAsHostUseCase _joinAsHostUseCase;

  JoinAsHostCubit(this._joinAsHostUseCase) : super(const JoinAsHostState());

  Future<void> join() async {
    if (state.status == JoinAsHostStatus.loading) return;

    emit(
      state.copyWith(
        status: JoinAsHostStatus.loading,
        errorMessage: () => null,
      ),
    );

    final result = await _joinAsHostUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: JoinAsHostStatus.failure,
          errorMessage: () => _mapFailureMessage(failure),
        ),
      ),
      (_) => emit(state.copyWith(status: JoinAsHostStatus.success)),
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
        : 'Unable to activate your host account right now. Please try again.';
  }
}
