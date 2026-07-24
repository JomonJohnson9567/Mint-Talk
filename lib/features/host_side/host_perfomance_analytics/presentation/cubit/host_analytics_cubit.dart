import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_call_statistics_usecase.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_performance_analytics_usecase.dart';
import 'host_analytics_state.dart';

@injectable
class HostAnalyticsCubit extends Cubit<HostAnalyticsState> {
  final GetPerformanceAnalyticsUseCase getPerformanceAnalyticsUseCase;
  final GetCallStatisticsUseCase getCallStatisticsUseCase;

  HostAnalyticsCubit({
    required this.getPerformanceAnalyticsUseCase,
    required this.getCallStatisticsUseCase,
  }) : super(const HostAnalyticsState());

  Future<void> loadAnalytics() async {
    emit(state.copyWith(status: HostAnalyticsStatus.loading));
    
    final ledgerResult = await getPerformanceAnalyticsUseCase(NoParams());
    final statsResult = await getCallStatisticsUseCase(NoParams());

    ledgerResult.fold(
      (failure) {
        emit(state.copyWith(
          status: HostAnalyticsStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (ledger) {
        statsResult.fold(
          (_) {
            emit(state.copyWith(
              status: HostAnalyticsStatus.loaded,
              ledger: ledger,
            ));
          },
          (callStats) {
            emit(state.copyWith(
              status: HostAnalyticsStatus.loaded,
              ledger: ledger,
              callStats: callStats,
            ));
          },
        );
      },
    );
  }
}
