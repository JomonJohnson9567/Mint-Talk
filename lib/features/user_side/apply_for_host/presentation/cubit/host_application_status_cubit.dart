import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_host_application_status_usecase.dart';
import 'host_application_status_state.dart';

@injectable
class HostApplicationStatusCubit extends Cubit<HostApplicationStatusState> {
  final GetHostApplicationStatusUseCase _getStatus;

  HostApplicationStatusCubit(this._getStatus)
    : super(const HostApplicationStatusState());

  Future<void> loadStatus() async {
    emit(
      const HostApplicationStatusState(view: HostApplicationStatusView.loading),
    );
    final result = await _getStatus();
    result.fold(
      (failure) => emit(
        HostApplicationStatusState(
          view: HostApplicationStatusView.failure,
          errorMessage: failure.message,
        ),
      ),
      (application) => emit(
        HostApplicationStatusState(
          view: HostApplicationStatusView.loaded,
          application: application,
        ),
      ),
    );
  }
}
