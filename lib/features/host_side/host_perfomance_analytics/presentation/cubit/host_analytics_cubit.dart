import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/host_side/host_targets/domain/usecases/get_host_targets_usecase.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_new_notifications_usecase.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_call_statistics_usecase.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/entities/host_earnings_ledger_entity.dart';
import '../../domain/usecases/get_performance_analytics_usecase.dart';
import 'host_analytics_state.dart';

@injectable
class HostAnalyticsCubit extends Cubit<HostAnalyticsState> {
  final GetPerformanceAnalyticsUseCase getPerformanceAnalyticsUseCase;
  final GetCallStatisticsUseCase getCallStatisticsUseCase;
  final GetHostTargetsUseCase getHostTargetsUseCase;
  final WatchNewNotificationsUseCase watchNewNotificationsUseCase;

  StreamSubscription<NotificationEntity>? _notificationSub;

  HostAnalyticsCubit({
    required this.getPerformanceAnalyticsUseCase,
    required this.getCallStatisticsUseCase,
    required this.getHostTargetsUseCase,
    required this.watchNewNotificationsUseCase,
  }) : super(const HostAnalyticsState()) {
    // A withdrawal status change (e.g. paid) moves earnings out of the
    // recent list and changes the available balance — reload the ledger.
    _notificationSub = watchNewNotificationsUseCase().listen((notification) {
      final text = '${notification.type} ${notification.title}'.toLowerCase();
      if (text.contains('withdraw') || text.contains('payout')) {
        _reloadLedger();
      }
    });
  }

  Future<void> loadAnalytics() async {
    emit(state.copyWith(status: HostAnalyticsStatus.loading));

    // Kick all three off concurrently, then await each individually — their
    // Either<Failure, T> result types differ, so they can't share one
    // Future.wait<T> list.
    final ledgerFuture = getPerformanceAnalyticsUseCase(state.scope);
    final statsFuture = getCallStatisticsUseCase(NoParams());
    final targetsFuture = getHostTargetsUseCase(NoParams());

    final ledgerResult = await ledgerFuture;
    final statsResult = await statsFuture;
    final targetsResult = await targetsFuture;
    if (isClosed) return;

    ledgerResult.fold(
      (failure) {
        emit(
          state.copyWith(
            status: HostAnalyticsStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (ledger) {
        emit(
          state.copyWith(
            status: HostAnalyticsStatus.loaded,
            ledger: ledger,
            callStats: statsResult.fold((_) => null, (callStats) => callStats),
            targets: targetsResult.fold((_) => const [], (targets) => targets),
          ),
        );
      },
    );
  }

  /// Switches between recent (unpaid) earnings and the full history.
  Future<void> selectScope(EarningsLedgerScope scope) async {
    if (scope == state.scope) return;
    final previous = state.scope;
    emit(state.copyWith(scope: scope));
    await _reloadLedger(revertTo: previous);
  }

  /// [revertTo]: scope to fall back to if this load fails, so the toggle
  /// never labels the previous scope's rows.
  Future<void> _reloadLedger({EarningsLedgerScope? revertTo}) async {
    if (state.ledger == null || isClosed) return;
    final scope = state.scope;
    emit(state.copyWith(isLedgerLoading: true));
    final result = await getPerformanceAnalyticsUseCase(scope);
    if (isClosed) return;
    // A newer scope switch superseded this load.
    if (scope != state.scope) return;
    result.fold(
      (_) => emit(state.copyWith(isLedgerLoading: false, scope: revertTo)),
      (ledger) => emit(state.copyWith(isLedgerLoading: false, ledger: ledger)),
    );
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    return super.close();
  }
}
