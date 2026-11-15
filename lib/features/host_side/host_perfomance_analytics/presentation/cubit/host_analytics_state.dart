import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/host_side/host_targets/domain/entities/host_target_entity.dart';
import 'package:mint_talk/features/user_side/call_log/domain/entities/call_statistics_report_entity.dart';
import '../../domain/entities/host_earnings_ledger_entity.dart';
import '../../domain/entities/host_leaderboard_entry_entity.dart';

enum HostAnalyticsStatus { initial, loading, loaded, failure }

class HostAnalyticsState extends Equatable {
  final HostAnalyticsStatus status;
  final HostEarningsLedgerEntity? ledger;

  /// Which ledger the list shows: unpaid recent earnings or full history.
  final EarningsLedgerScope scope;

  /// True while only the ledger list is reloading (scope switch).
  final bool isLedgerLoading;
  final CallStatisticsReportEntity? callStats;
  final List<HostTargetEntity> targets;

  // TODO: populate once the backend exposes a weekly host leaderboard and a
  // date-range filter on the earnings ledger — the screen hides the
  // leaderboard and period chip while these are empty/null.
  final List<HostLeaderboardEntryEntity> leaderboard;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  final String? errorMessage;

  const HostAnalyticsState({
    this.status = HostAnalyticsStatus.initial,
    this.ledger,
    this.scope = EarningsLedgerScope.recent,
    this.isLedgerLoading = false,
    this.callStats,
    this.targets = const [],
    this.leaderboard = const [],
    this.periodStart,
    this.periodEnd,
    this.errorMessage,
  });

  HostAnalyticsState copyWith({
    HostAnalyticsStatus? status,
    HostEarningsLedgerEntity? ledger,
    EarningsLedgerScope? scope,
    bool? isLedgerLoading,
    CallStatisticsReportEntity? callStats,
    List<HostTargetEntity>? targets,
    List<HostLeaderboardEntryEntity>? leaderboard,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? errorMessage,
  }) {
    return HostAnalyticsState(
      status: status ?? this.status,
      ledger: ledger ?? this.ledger,
      scope: scope ?? this.scope,
      isLedgerLoading: isLedgerLoading ?? this.isLedgerLoading,
      callStats: callStats ?? this.callStats,
      targets: targets ?? this.targets,
      leaderboard: leaderboard ?? this.leaderboard,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading =>
      status == HostAnalyticsStatus.initial ||
      status == HostAnalyticsStatus.loading;

  bool get hasPeriod => periodStart != null && periodEnd != null;

  @override
  List<Object?> get props => [
    status,
    ledger,
    scope,
    isLedgerLoading,
    callStats,
    targets,
    leaderboard,
    periodStart,
    periodEnd,
    errorMessage,
  ];
}
