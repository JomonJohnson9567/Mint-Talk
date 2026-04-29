import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final String orderId;
  final int amount;
  final String currency;
  final String transactionId;
  final String key;
  final int pointsToCredit;

  const OrderEntity({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.transactionId,
    required this.key,
    required this.pointsToCredit,
  });

  @override
  List<Object?> get props => [
        orderId,
        amount,
        currency,
        transactionId,
        key,
        pointsToCredit,
      ];
}
