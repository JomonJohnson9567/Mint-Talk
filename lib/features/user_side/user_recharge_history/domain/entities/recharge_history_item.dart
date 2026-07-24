import 'package:equatable/equatable.dart';

class RechargeHistoryItem extends Equatable {
  final String transactionId;
  final num amount;
  final String currency;
  final int points;
  final String status;
  final DateTime createdAt;

  const RechargeHistoryItem({
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.points,
    required this.status,
    required this.createdAt,
  });

  bool get isCompleted => status.toLowerCase() == 'completed';

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isFailed =>
      status.toLowerCase() == 'failed' || status.toLowerCase() == 'error';

  @override
  List<Object?> get props => [
        transactionId,
        amount,
        currency,
        points,
        status,
        createdAt,
      ];
}
