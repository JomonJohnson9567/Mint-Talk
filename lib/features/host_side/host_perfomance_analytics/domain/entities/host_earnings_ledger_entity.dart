import 'package:equatable/equatable.dart';

class HostEarningsLedgerSummaryEntity extends Equatable {
  final double totalGrossInr;
  final double totalCommissionInr;
  final double totalTdsInr;
  final double totalNetInr;
  final int totalBilledPoints;
  final int totalCalls;

  const HostEarningsLedgerSummaryEntity({
    required this.totalGrossInr,
    required this.totalCommissionInr,
    required this.totalTdsInr,
    required this.totalNetInr,
    required this.totalBilledPoints,
    required this.totalCalls,
  });

  @override
  List<Object?> get props => [
        totalGrossInr,
        totalCommissionInr,
        totalTdsInr,
        totalNetInr,
        totalBilledPoints,
        totalCalls,
      ];
}

class HostEarningCallInfoEntity extends Equatable {
  final String id;
  final String callType;
  final int duration;
  final String status;

  const HostEarningCallInfoEntity({
    required this.id,
    required this.callType,
    required this.duration,
    required this.status,
  });

  @override
  List<Object?> get props => [id, callType, duration, status];
}

class HostEarningEntryEntity extends Equatable {
  final String id;
  final String hostId;
  final String earningType;
  final double grossEarningInr;
  final double platformCommissionRate;
  final double platformCommissionInr;
  final double tdsRate;
  final double taxDeductedInr;
  final double netEarningInr;
  final String billingPolicy;
  final int? ratePerMinute;
  final int? billedMinutes;
  final int? billedPoints;
  final DateTime createdAt;
  final HostEarningCallInfoEntity? callInfo;
  final Map<String, dynamic>? metadata;

  const HostEarningEntryEntity({
    required this.id,
    required this.hostId,
    required this.earningType,
    required this.grossEarningInr,
    required this.platformCommissionRate,
    required this.platformCommissionInr,
    required this.tdsRate,
    required this.taxDeductedInr,
    required this.netEarningInr,
    required this.billingPolicy,
    required this.createdAt,
    this.ratePerMinute,
    this.billedMinutes,
    this.billedPoints,
    this.callInfo,
    this.metadata,
  });

  bool get isCall => callInfo != null || earningType == 'call';
  bool get isReferral => earningType == 'referral';

  @override
  List<Object?> get props => [
        id,
        hostId,
        earningType,
        grossEarningInr,
        platformCommissionRate,
        platformCommissionInr,
        tdsRate,
        taxDeductedInr,
        netEarningInr,
        billingPolicy,
        ratePerMinute,
        billedMinutes,
        billedPoints,
        createdAt,
        callInfo,
        metadata,
      ];
}

class HostEarningsLedgerEntity extends Equatable {
  final HostEarningsLedgerSummaryEntity summary;
  final List<HostEarningEntryEntity> earnings;
  final int page;
  final int limit;
  final int total;

  const HostEarningsLedgerEntity({
    required this.summary,
    required this.earnings,
    required this.page,
    required this.limit,
    required this.total,
  });

  bool get hasMore => page * limit < total;

  @override
  List<Object?> get props => [summary, earnings, page, limit, total];
}
