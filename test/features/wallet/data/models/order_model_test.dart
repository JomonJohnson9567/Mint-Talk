import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/wallet/data/models/order_model.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('should parse correctly with camelCase keys', () {
      final json = {
        'orderId': 'order_123',
        'amount': 50000,
        'currency': 'INR',
        'transactionId': 'trans_456',
        'key': 'rzp_key_789',
        'pointsToCredit': 100
      };

      final model = OrderModel.fromJson(json);

      expect(model.orderId, 'order_123');
      expect(model.amount, 50000);
      expect(model.currency, 'INR');
      expect(model.transactionId, 'trans_456');
      expect(model.key, 'rzp_key_789');
      expect(model.pointsToCredit, 100);
    });

    test('should parse correctly with snake_case keys', () {
      final json = {
        'order_id': 'order_123',
        'amount_due': 50000,
        'currency': 'USD',
        'transaction_id': 'trans_456',
        'razorpay_key': 'rzp_key_789',
        'points_to_credit': 200
      };

      final model = OrderModel.fromJson(json);

      expect(model.orderId, 'order_123');
      expect(model.amount, 50000);
      expect(model.currency, 'USD');
      expect(model.transactionId, 'trans_456');
      expect(model.key, 'rzp_key_789');
      expect(model.pointsToCredit, 200);
    });

    test('should parse correctly with "id" for orderId and "key_id" for key', () {
      final json = {
        'id': 'order_id_from_id',
        'amount': 1000,
        'key_id': 'key_from_key_id',
      };

      final model = OrderModel.fromJson(json);

      expect(model.orderId, 'order_id_from_id');
      expect(model.key, 'key_from_key_id');
    });

    test('should provide default values for missing keys', () {
      final json = <String, dynamic>{};

      final model = OrderModel.fromJson(json);

      expect(model.orderId, '');
      expect(model.amount, 0);
      expect(model.currency, 'INR');
      expect(model.key, '');
    });
  });
}
