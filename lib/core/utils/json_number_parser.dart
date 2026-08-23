/// Parses a JSON value into an [int], tolerating shapes stricter parsing
/// (`value is int ? value : int.tryParse(value.toString())`) silently drops:
/// a whole-number [double] (MongoDB/JS backends commonly store — and can
/// serialize — plain numbers as doubles, e.g. `120.0` instead of `120`), a
/// genuinely fractional value that should have been rounded server-side
/// but wasn't (e.g. `2.0833333` for a billed-minutes field that skipped a
/// `Math.ceil`), or a numeric value sent as a string (`"120"` / `"120.0"`).
///
/// `int.tryParse('120.0')` returns null — silently. That failure mode is
/// exactly what made a real, correctly-computed billing field parse to
/// null (and then default to 0) while a sibling field in the same JSON
/// response, one that happened to arrive as a clean integer, parsed fine.
class JsonNumberParser {
  JsonNumberParser._();

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();

    final asString = value.toString();
    return int.tryParse(asString) ?? double.tryParse(asString)?.round();
  }
}
