// Regression test: the wallet balance API can return a fractional balance
// (per-second billing debits partial points, e.g. 79940.4952999999), and
// WalletModel.fromJson used to assign that straight into an `int` field,
// throwing a runtime TypeError and making every balance fetch fail.
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/wallet/data/models/wallet_model.dart';

void main() {
  group('WalletModel.fromJson', () {
    test('rounds a fractional balance instead of throwing', () {
      final json = {'balance': 79940.4952999999, 'status': 'active'};

      final model = WalletModel.fromJson(json);

      expect(model.balance, 79940);
      expect(model.status, 'active');
    });

    test('parses a whole-number balance as-is', () {
      final json = {'balance': 500, 'status': 'active'};

      final model = WalletModel.fromJson(json);

      expect(model.balance, 500);
    });

    test('defaults to 0 when balance is missing', () {
      final json = {'status': 'active'};

      final model = WalletModel.fromJson(json);

      expect(model.balance, 0);
    });
  });
}
