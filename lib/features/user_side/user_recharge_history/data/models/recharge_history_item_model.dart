import '../../domain/entities/recharge_history_item.dart';

class RechargeHistoryItemModel extends RechargeHistoryItem {
  const RechargeHistoryItemModel({
    required super.transactionId,
    required super.amount,
    required super.currency,
    required super.points,
    required super.status,
    required super.createdAt,
  });

  factory RechargeHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return RechargeHistoryItemModel(
      transactionId: json['transactionId']?.toString() ??
          json['transaction_id']?.toString() ??
          '',
      amount: (json['amount'] as num?) ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      points: (json['points'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'unknown',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
