import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_host_call_logs_usecase.dart';
import '../../domain/usecases/get_user_call_logs_usecase.dart';
import 'call_log_state.dart';

@injectable
class CallLogCubit extends Cubit<CallLogState> {
  final GetUserCallLogsUseCase getUserCallLogsUseCase;
  final GetHostCallLogsUseCase getHostCallLogsUseCase;

  CallLogCubit({
    required this.getUserCallLogsUseCase,
    required this.getHostCallLogsUseCase,
  }) : super(const CallLogInitial());

  Future<void> loadCallLogs({bool isHost = false, String? status}) async {
    emit(const CallLogLoading());

    final params = GetCallLogsParams(status: status);
    final result = isHost
        ? await getHostCallLogsUseCase(params)
        : await getUserCallLogsUseCase(params);

    result.fold(
      (failure) => emit(CallLogError(failure.message)),
      (entities) {
        final entries = entities
            .map((entity) => CallLogEntry.fromCallLogEntity(entity))
            .toList();
        emit(CallLogLoaded(entries));
      },
    );
  }
}
