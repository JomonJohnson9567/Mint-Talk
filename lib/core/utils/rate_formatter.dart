import 'package:mint_talk/core/constants/app_texts.dart';

/// Formats a per-minute host rate for display, honoring the app-wide
/// `billingUnit` from `SystemConfigCubit` ('minute' or 'second'). Host rate
/// fields (audioRate/videoRate) are always stored/transmitted per-minute —
/// only the display converts to per-second.
class RateFormatter {
  RateFormatter._();

  static String label(
    num? ratePerMinute,
    String billingUnit, {
    String unit = 'pts',
  }) {
    final value = billingUnit == 'second' && ratePerMinute != null
        ? ratePerMinute / 60
        : ratePerMinute;
    return raw(value, billingUnit, unit: unit);
  }

  /// Formats a rate that is already expressed in [billingUnit] (e.g. the
  /// system-config default rates) — only appends the suffix, no conversion.
  static String raw(num? rate, String billingUnit, {String unit = 'pts'}) {
    final suffix = billingUnit == 'second' ? '/sec' : '/min';
    final valueText = rate == null ? '--' : _trim(rate);
    final unitText = unit.isEmpty ? '' : ' $unit';
    return '$valueText$unitText$suffix';
  }

  /// Formats a host earning rate already expressed in ₹ per
  /// [hostBillingUnit] ('second' or 'minute'), e.g. `₹20/sec` or `₹15/min`.
  /// No conversion — the number and unit are shown exactly as configured.
  static String inr(num? rate, String hostBillingUnit) {
    final suffix = hostBillingUnit == 'second' ? '/sec' : '/min';
    final valueText = rate == null ? '--' : _trim(rate);
    return '${AppTexts.rupeeSymbol}$valueText$suffix';
  }

  static String _trim(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}
