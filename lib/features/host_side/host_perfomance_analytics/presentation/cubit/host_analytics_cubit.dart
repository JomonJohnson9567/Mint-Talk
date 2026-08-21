import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/host_side/host_targets/domain/usecases/get_host_targets_usecase.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_call_statistics_usecase.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_performance_analytics_usecase.dart';
import 'host_analytics_state.dart';

@injectable
class HostAnalyticsCubit extends Cubit<HostAnalyticsState> {
  final GetPerformanceAnalyticsUseCase getPerformanceAnalyticsUseCase;
  final GetCallStatisticsUseCase getCallStatisticsUseCase;
  final GetHostTargetsUseCase getHostTargetsUseCase;

  HostAnalyticsCubit({
    required this.getPerformanceAnalyticsUseCase,
    required this.getCallStatisticsUseCase,
    required this.getHostTargetsUseCase,
  }) : super(const HostAnalyticsState());

  Future<void> loadAnalytics() async {
    emit(state.copyWith(status: HostAnalyticsStatus.loading));

    // Kick all three off concurrently, then await each individually — their
    // Either<Failure, T> result types differ, so they can't share one
    // Future.wait<T> list.
    final ledgerFuture = getPerformanceAnalyticsUseCase(NoParams());
    final statsFuture = getCallStatisticsUseCase(NoParams());
    final targetsFuture = getHostTargetsUseCase(NoParams());

    final ledgerResult = await ledgerFuture;
    final statsResult = await statsFuture;
    final targetsResult = await targetsFuture;

    ledgerResult.fold(
      (failure) {
        emit(state.copyWith(
          status: HostAnalyticsStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (ledger) {
        emit(state.copyWith(
          status: HostAnalyticsStatus.loaded,
          ledger: ledger,
          callStats: statsResult.fold((_) => null, (callStats) => callStats),
          targets: targetsResult.fold((_) => const [], (targets) => targets),
        ));
      },
    );
  }
}
