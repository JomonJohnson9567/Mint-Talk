import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/withdrawal_amount_validator.dart';

void main() {
  WithdrawalAmountError? validate(String text, {double available = 500}) =>
      WithdrawalAmountValidator.validate(
        text,
        minimum: 100,
        available: available,
      );

  test('minimum and available balance are both inclusive', () {
    expect(validate('100'), isNull);
    expect(validate('500'), isNull);
    expect(validate('100', available: 100), isNull);
  });

  test('balance ₹99 with ₹100 minimum cannot withdraw anything', () {
    expect(validate('99', available: 99), WithdrawalAmountError.belowMinimum);
    expect(validate('100', available: 99), WithdrawalAmountError.aboveBalance);
  });

  test('rejects below minimum and above balance', () {
    expect(validate('99.99'), WithdrawalAmountError.belowMinimum);
    expect(validate('500.01'), WithdrawalAmountError.aboveBalance);
  });

  test('allows up to two decimals only', () {
    expect(validate('150.5'), isNull);
    expect(validate('150.55'), isNull);
    expect(validate('150.555'), WithdrawalAmountError.tooManyDecimals);
  });

  test('rejects empty and malformed input', () {
    expect(validate(''), WithdrawalAmountError.empty);
    expect(validate('  '), WithdrawalAmountError.empty);
    expect(validate('abc'), WithdrawalAmountError.invalid);
    expect(validate('-100'), WithdrawalAmountError.invalid);
    expect(validate('1e3'), WithdrawalAmountError.invalid);
    expect(validate('0'), WithdrawalAmountError.invalid);
  });

  test('compares in paise, avoiding float drift', () {
    expect(
      WithdrawalAmountValidator.validate(
        '100.10',
        minimum: 100.1,
        available: 100.1,
      ),
      isNull,
    );
  });
}
