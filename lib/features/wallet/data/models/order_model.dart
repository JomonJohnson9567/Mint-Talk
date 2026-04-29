import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mint_talk/features/wallet/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.amount,
    required super.currency,
    required super.transactionId,
    required super.key,
    required super.pointsToCredit,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // ignore: avoid_print
    print('OrderModel.fromJson: Received raw map: $json');
    
    // Look for order ID in common places
    final orderId = (json['orderId'] ?? json['order_id'] ?? json['razorpay_order_id'] ?? json['id'] ?? '').toString();
    
    // Look for key in common places, with .env fallback
    String key = (json['key'] ?? json['key_id'] ?? json['razorpay_key'] ?? json['merchantKey'] ?? json['merchant_key'] ?? json['apiKey'] ?? json['api_key'] ?? '').toString();
    
    if (key.isEmpty) {
      key = dotenv.env['RAZORPAY_KEY'] ?? '';
      // ignore: avoid_print
      if (key.isNotEmpty) print('OrderModel.fromJson: Using RAZORPAY_KEY fallback from .env');
    }

    final model = OrderModel(
      orderId: orderId,
      amount: json['amount'] ?? json['amount_due'] ?? 0,
      currency: json['currency'] ?? 'INR',
      transactionId: (json['transactionId'] ?? json['transaction_id'] ?? '').toString(),
      key: key,
      pointsToCredit: json['pointsToCredit'] ?? json['points_to_credit'] ?? 0,
    );

    // ignore: avoid_print
    print('OrderModel.fromJson: Successfully parsed -> orderId: ${model.orderId}, key: ${model.key == '' ? 'EMPTY' : 'PRESENT'}, amount: ${model.amount}');
    
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'key': key,
      'pointsToCredit': pointsToCredit,
    };
  }
}
