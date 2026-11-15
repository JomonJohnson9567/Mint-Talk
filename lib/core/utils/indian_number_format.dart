/// Groups digits the Indian way (lakh/crore): the last three digits, then
/// pairs — `180000` → `1,80,000`, `1000000` → `10,00,000`. The project has no
/// `intl` dependency, and coin/price labels are the only place this is needed.
class IndianNumberFormat {
  IndianNumberFormat._();

  static String format(num value) {
    final negative = value < 0;
    final abs = value.abs();
    final isWhole = abs == abs.roundToDouble();
    final fixed = isWhole ? abs.toInt().toString() : abs.toStringAsFixed(2);

    final parts = fixed.split('.');
    final grouped = _group(parts[0]);
    final fraction = parts.length > 1 ? '.${parts[1]}' : '';
    return '${negative ? '-' : ''}$grouped$fraction';
  }

  static String _group(String digits) {
    if (digits.length <= 3) return digits;

    final lastThree = digits.substring(digits.length - 3);
    final rest = digits.substring(0, digits.length - 3);
    final pairs = <String>[];
    for (var end = rest.length; end > 0; end -= 2) {
      pairs.insert(0, rest.substring(end - 2 < 0 ? 0 : end - 2, end));
    }
    return '${pairs.join(',')},$lastThree';
  }
}
