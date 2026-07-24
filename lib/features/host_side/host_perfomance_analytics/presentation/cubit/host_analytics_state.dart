import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/call_log/domain/entities/call_statistics_report_entity.dart';
import '../../domain/entities/host_earnings_ledger_entity.dart';

enum HostAnalyticsStatus { initial, loading, loaded, failure }

class HostAnalyticsState extends Equatable {
  final HostAnalyticsStatus status;
  final HostEarningsLedgerEntity? ledger;
  final CallStatisticsReportEntity? callStats;
  final String? errorMessage;

  const HostAnalyticsState({
    this.status = HostAnalyticsStatus.initial,
    this.ledger,
    this.callStats,
    this.errorMessage,
  });

  HostAnalyticsState copyWith({
    HostAnalyticsStatus? status,
    HostEarningsLedgerEntity? ledger,
    CallStatisticsReportEntity? callStats,
    String? errorMessage,
  }) {
    return HostAnalyticsState(
      status: status ?? this.status,
      ledger: ledger ?? this.ledger,
      callStats: callStats ?? this.callStats,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading =>
      status == HostAnalyticsStatus.initial ||
      status == HostAnalyticsStatus.loading;

  @override
  List<Object?> get props => [status, ledger, callStats, errorMessage];
}
