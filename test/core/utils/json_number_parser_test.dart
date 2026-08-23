// Regression test for a real failure mode: int.tryParse(value.toString())
// silently returns null for any decimal-point string ("120.0"), which is
// exactly what let a correctly-computed billing field parse to null (then
// default to 0) while a sibling field in the same JSON response — one that
// happened to arrive as a clean integer — parsed fine.
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/utils/json_number_parser.dart';

void main() {
  group('JsonNumberParser.parseInt', () {
    test('returns null for null', () {
      expect(JsonNumberParser.parseInt(null), isNull);
    });

    test('passes through a plain int unchanged', () {
      expect(JsonNumberParser.parseInt(120), 120);
    });

    test('rounds a whole-number double (e.g. MongoDB/JS number serialization)', () {
      expect(JsonNumberParser.parseInt(120.0), 120);
    });

    test('rounds a genuinely fractional double (e.g. an un-rounded division)', () {
      expect(JsonNumberParser.parseInt(2.0833333), 2);
    });

    test('parses a stringified plain integer', () {
      expect(JsonNumberParser.parseInt('120'), 120);
    });

    test('parses a stringified decimal number', () {
      expect(JsonNumberParser.parseInt('120.0'), 120);
    });

    test('returns null for a non-numeric string', () {
      expect(JsonNumberParser.parseInt('not-a-number'), isNull);
    });
  });
}
