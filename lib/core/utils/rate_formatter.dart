/// Formats a per-minute host rate for display, honoring the app-wide
/// `billingUnit` from `SystemConfigCubit` ('minute' or 'second'). Host rate
/// fields (audioRate/videoRate) are always stored/transmitted per-minute —
/// only the display converts to per-second.
class RateFormatter {
  RateFormatter._();

  static String label(num? ratePerMinute, String billingUnit, {String unit = 'pts'}) {
    final suffix = billingUnit == 'second' ? '/sec' : '/min';
    final value = billingUnit == 'second' && ratePerMinute != null
        ? ratePerMinute / 60
        : ratePerMinute;
    final valueText = value == null ? '--' : _trim(value);
    final unitText = unit.isEmpty ? '' : ' $unit';
    return '$valueText$unitText$suffix';
  }

  static String _trim(num value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}
