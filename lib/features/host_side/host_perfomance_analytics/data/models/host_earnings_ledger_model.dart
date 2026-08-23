import '../../domain/entities/host_earnings_ledger_entity.dart';

class HostEarningsLedgerSummaryModel extends HostEarningsLedgerSummaryEntity {
  const HostEarningsLedgerSummaryModel({
    required super.totalGrossInr,
    required super.totalCommissionInr,
    required super.totalTdsInr,
    required super.totalNetInr,
    required super.totalBilledPoints,
    required super.totalCalls,
  });

  factory HostEarningsLedgerSummaryModel.fromJson(Map<String, dynamic> json) {
    return HostEarningsLedgerSummaryModel(
      totalGrossInr: (json['totalGrossINR'] as num? ?? 0).toDouble(),
      totalCommissionInr: (json['totalCommissionINR'] as num? ?? 0).toDouble(),
      totalTdsInr: (json['totalTdsINR'] as num? ?? 0).toDouble(),
      totalNetInr: (json['totalNetINR'] as num? ?? 0).toDouble(),
      totalBilledPoints: (json['totalBilledPoints'] as num?)?.toInt() ?? 0,
      totalCalls: (json['totalCalls'] as num?)?.toInt() ?? 0,
    );
  }
}

class HostEarningCallInfoModel extends HostEarningCallInfoEntity {
  const HostEarningCallInfoModel({
    required super.id,
    required super.callType,
    required super.duration,
    required super.status,
  });

  factory HostEarningCallInfoModel.fromJson(Map<String, dynamic> json) {
    return HostEarningCallInfoModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      callType: json['callType'] as String? ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}

class HostEarningEntryModel extends HostEarningEntryEntity {
  const HostEarningEntryModel({
    required super.id,
    required super.hostId,
    required super.earningType,
    required super.grossEarningInr,
    required super.platformCommissionRate,
    required super.platformCommissionInr,
    required super.tdsRate,
    required super.taxDeductedInr,
    required super.netEarningInr,
    required super.billingPolicy,
    required super.createdAt,
    super.ratePerMinute,
    super.billedMinutes,
    super.billedPoints,
    super.callInfo,
    super.metadata,
  });

  factory HostEarningEntryModel.fromJson(Map<String, dynamic> json) {
    final callJson = json['callId'];
    final metadata = json['metadata'];
    return HostEarningEntryModel(
      id: json['_id'] as String? ?? '',
      hostId: json['hostId'] as String? ?? '',
      earningType: json['earningType'] as String? ?? '',
      grossEarningInr: (json['grossEarningINR'] as num? ?? 0).toDouble(),
      platformCommissionRate:
          (json['platformCommissionRate'] as num? ?? 0).toDouble(),
      platformCommissionInr:
          (json['platformCommissionINR'] as num? ?? 0).toDouble(),
      tdsRate: (json['tdsRate'] as num? ?? 0).toDouble(),
      taxDeductedInr: (json['taxDeductedINR'] as num? ?? 0).toDouble(),
      netEarningInr: (json['netEarningINR'] as num? ?? 0).toDouble(),
      billingPolicy: json['billingPolicy'] as String? ?? '',
      ratePerMinute: (json['ratePerMinute'] as num?)?.toInt(),
      billedMinutes: (json['billedMinutes'] as num?)?.toInt(),
      billedPoints: (json['billedPoints'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      callInfo: callJson is Map<String, dynamic>
          ? HostEarningCallInfoModel.fromJson(callJson)
          : null,
      metadata: metadata is Map<String, dynamic>
          ? Map<String, dynamic>.from(metadata)
          : null,
    );
  }
}

class HostEarningsLedgerModel extends HostEarningsLedgerEntity {
  const HostEarningsLedgerModel({
    required super.summary,
    required super.earnings,
    required super.page,
    required super.limit,
    required super.total,
  });

  factory HostEarningsLedgerModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? const {});
    final summary = HostEarningsLedgerSummaryModel.fromJson(
      data['summary'] as Map<String, dynamic>? ?? const {},
    );
    final earnings = (data['earnings'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HostEarningEntryModel.fromJson)
        .toList();

    return HostEarningsLedgerModel(
      summary: summary,
      earnings: earnings,
      page: (data['page'] as num?)?.toInt() ?? 1,
      limit: (data['limit'] as num?)?.toInt() ?? earnings.length,
      total: (data['total'] as num?)?.toInt() ?? earnings.length,
    );
  }
}
