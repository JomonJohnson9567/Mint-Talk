import '../../domain/entities/host_wallet_entities.dart';

class HostWithdrawalEntryModel extends HostWithdrawalEntryEntity {
  const HostWithdrawalEntryModel({
    required super.id,
    required super.amount,
    required super.payoutMethod,
    required super.status,
    required super.createdAt,
  });

  factory HostWithdrawalEntryModel.fromJson(Map<String, dynamic> json) {
    return HostWithdrawalEntryModel(
      id: json['_id'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0).toDouble(),
      payoutMethod: json['payoutMethod'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class HostWalletOverviewModel extends HostWalletOverviewEntity {
  const HostWalletOverviewModel({
    required super.withdrawableBalance,
    required super.withdrawals,
    required super.page,
    required super.limit,
    required super.total,
  });

  factory HostWalletOverviewModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? const {});
    final withdrawals = (data['withdrawals'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HostWithdrawalEntryModel.fromJson)
        .toList();

    return HostWalletOverviewModel(
      withdrawableBalance: (data['withdrawableBalance'] as num? ?? 0).toDouble().round(),
      withdrawals: withdrawals,
      page: data['page'] as int? ?? 1,
      limit: data['limit'] as int? ?? withdrawals.length,
      total: data['total'] as int? ?? withdrawals.length,
    );
  }
}

class HostWithdrawalRequestModel extends HostWithdrawalRequestParams {
  const HostWithdrawalRequestModel({
    required super.amount,
    required super.payoutMethod,
    super.bankName,
    super.accountNumber,
    super.ifsc,
    super.holderName,
    super.upiId,
  });

  Map<String, dynamic> toJson() {
    final details = <String, dynamic>{};
    if ((bankName ?? '').isNotEmpty) details['bankName'] = bankName;
    if ((accountNumber ?? '').isNotEmpty) details['accountNumber'] = accountNumber;
    if ((ifsc ?? '').isNotEmpty) details['ifsc'] = ifsc;
    if ((holderName ?? '').isNotEmpty) details['holderName'] = holderName;
    if ((upiId ?? '').isNotEmpty) details['upiId'] = upiId;

    return {
      'amount': amount.round(),
      'payoutMethod': payoutMethod,
      if (details.isNotEmpty) 'payoutDetails': details,
    };
  }
}
