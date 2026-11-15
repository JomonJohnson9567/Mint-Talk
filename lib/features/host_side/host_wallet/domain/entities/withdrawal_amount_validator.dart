/// Why a typed withdrawal amount can't be sent.
enum WithdrawalAmountError {
  empty,
  invalid,
  tooManyDecimals,
  belowMinimum,
  aboveBalance,
}

/// Client-side pre-check of the amount field. The backend re-validates every
/// request; this only stops obviously invalid ones from being sent.
abstract final class WithdrawalAmountValidator {
  static final RegExp _format = RegExp(r'^\d+(\.\d*)?$');

  /// Parses [text] as INR. Returns null for anything that isn't a plain
  /// non-negative decimal (no signs, exponents or separators).
  static double? parse(String text) {
    final value = text.trim();
    if (!_format.hasMatch(value)) return null;
    return double.tryParse(value);
  }

  /// `minimum ≤ amount ≤ available`, both ends inclusive, at most two
  /// decimals. Compared in paise so `100.10` vs `100.1` can't drift.
  static WithdrawalAmountError? validate(
    String text, {
    required double minimum,
    required double available,
  }) {
    final value = text.trim();
    if (value.isEmpty) return WithdrawalAmountError.empty;

    final amount = parse(value);
    if (amount == null || amount <= 0) return WithdrawalAmountError.invalid;

    final dot = value.indexOf('.');
    if (dot != -1 && value.length - dot - 1 > 2) {
      return WithdrawalAmountError.tooManyDecimals;
    }

    final paise = (amount * 100).round();
    if (paise < (minimum * 100).round()) {
      return WithdrawalAmountError.belowMinimum;
    }
    if (paise > (available * 100).round()) {
      return WithdrawalAmountError.aboveBalance;
    }
    return null;
  }
}
