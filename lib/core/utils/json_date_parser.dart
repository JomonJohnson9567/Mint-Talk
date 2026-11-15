/// Parses a server timestamp into a local [DateTime]. Accepts an ISO-8601
/// string (`"2026-10-17T09:12:30.123Z"`) or epoch milliseconds (as a number
/// or numeric string), since the backend has used both shapes.
class JsonDateParser {
  JsonDateParser._();

  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value.toLocal();
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
    }
    final asString = value.toString().trim();
    if (asString.isEmpty) return null;
    final asEpoch = int.tryParse(asString);
    if (asEpoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(asEpoch).toLocal();
    }
    return DateTime.tryParse(asString)?.toLocal();
  }
}
