import 'package:flutter/foundation.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/order_entity.dart';

class OrderModel {
  final String orderId;
  final int amount;
  final String currency;
  final String transactionId;
  final String key;
  final int pointsToCredit;

  const OrderModel({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.transactionId,
    required this.key,
    required this.pointsToCredit,
  });

  /// [fallbackRazorpayKey] is used only when the response body doesn't carry
  /// a key under any of the recognized field names — passed in by the caller
  /// (typically `EnvConfig.razorpayKey`) rather than resolved here via the
  /// service locator, so this DTO stays a pure parsing function.
  factory OrderModel.fromJson(Map<String, dynamic> json, {String? fallbackRazorpayKey}) {
    if (kDebugMode) {
      appLogger.d('OrderModel.fromJson: Received raw map: $json');
    }

    // Look for order ID in common places
    final orderId = (json['orderId'] ?? json['order_id'] ?? json['razorpay_order_id'] ?? json['id'] ?? '').toString();

    // Look for key in common places, with .env fallback
    String key = (json['key'] ?? json['key_id'] ?? json['razorpay_key'] ?? json['merchantKey'] ?? json['merchant_key'] ?? json['apiKey'] ?? json['api_key'] ?? '').toString();

    if (key.isEmpty && fallbackRazorpayKey != null && fallbackRazorpayKey.isNotEmpty) {
      key = fallbackRazorpayKey;
      appLogger.d('OrderModel.fromJson: Using RAZORPAY_KEY fallback from EnvConfig');
    }

    final model = OrderModel(
      orderId: orderId,
      amount: json['amount'] ?? json['amount_due'] ?? 0,
      currency: json['currency'] ?? 'INR',
      transactionId: (json['transactionId'] ?? json['transaction_id'] ?? '').toString(),
      key: key,
      pointsToCredit: json['pointsToCredit'] ?? json['points_to_credit'] ?? 0,
    );

    appLogger.d('OrderModel.fromJson: Successfully parsed -> orderId: ${model.orderId}, key: ${model.key == '' ? 'EMPTY' : 'PRESENT'}, amount: ${model.amount}');
    
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

  OrderEntity toEntity() => OrderEntity(
        orderId: orderId,
        amount: amount,
        currency: currency,
        transactionId: transactionId,
        key: key,
        pointsToCredit: pointsToCredit,
      );
}
