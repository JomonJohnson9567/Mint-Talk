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
  }) : super(const CallLogState());

  Future<void> loadCallLogs({bool isHost = false, String? status}) async {
    // A pull-to-refresh keeps the current rows on screen instead of
    // flashing the skeleton.
    if (state.callLogs.isEmpty) {
      emit(
        state.copyWith(status: CallLogStatus.loading, errorMessage: () => null),
      );
    }

    final params = GetCallLogsParams(status: status);
    final result = isHost
        ? await getHostCallLogsUseCase(params)
        : await getUserCallLogsUseCase(params);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CallLogStatus.failure,
          errorMessage: () => failure.message,
        ),
      ),
      (entities) {
        final entries =
            entities
                .map((entity) => CallLogEntry.fromCallLogEntity(entity))
                .toList()
              ..sort((a, b) {
                final aTime = a.createdAt;
                final bTime = b.createdAt;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });
        emit(
          state.copyWith(
            status: CallLogStatus.loaded,
            callLogs: entries,
            errorMessage: () => null,
          ),
        );
      },
    );
  }

  void search(String query) => emit(state.copyWith(query: query));

  void setTypeFilter(CallLogTypeFilter filter) =>
      emit(state.copyWith(typeFilter: filter));

  void setStatusFilter(CallLogStatusFilter filter) =>
      emit(state.copyWith(statusFilter: filter));
}
