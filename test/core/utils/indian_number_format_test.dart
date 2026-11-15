import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';

void main() {
  group('IndianNumberFormat.format', () {
    test('leaves numbers under a thousand ungrouped', () {
      expect(IndianNumberFormat.format(0), '0');
      expect(IndianNumberFormat.format(500), '500');
    });

    test('groups thousands like the western format', () {
      expect(IndianNumberFormat.format(1000), '1,000');
      expect(IndianNumberFormat.format(40000), '40,000');
    });

    test('groups lakhs and crores in pairs', () {
      expect(IndianNumberFormat.format(180000), '1,80,000');
      expect(IndianNumberFormat.format(1000000), '10,00,000');
      expect(IndianNumberFormat.format(15000000), '1,50,00,000');
    });

    test('drops the fraction of a whole-number double', () {
      expect(IndianNumberFormat.format(12500.0), '12,500');
    });

    test('keeps two decimals for a fractional value', () {
      expect(IndianNumberFormat.format(1499.5), '1,499.50');
    });

    test('keeps the sign of a negative value', () {
      expect(IndianNumberFormat.format(-250000), '-2,50,000');
    });
  });
}
