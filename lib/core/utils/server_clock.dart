import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

/// An estimate of the backend's wall clock, independent of the device's.
///
/// Server timestamps (a call's `activeAt`, for example) can't be compared
/// against `DateTime.now()` directly: the device clock may be minutes off,
/// and that error lands straight in anything derived from the difference —
/// a device running 90 s fast shows a freshly-connected call at 1:30.
///
/// The clock is anchored on server time observed from HTTP `Date` headers
/// (see `ServerTimeInterceptor`) and advanced with a monotonic [Stopwatch],
/// so once synced it is also immune to the device clock being changed
/// mid-session (NTP correction, user edit). Until the first sample arrives
/// it falls back to the device clock — the previous behaviour.
@lazySingleton
class ServerClock {
  ServerClock() : this.withSources();

  @visibleForTesting
  ServerClock.withSources({
    Stopwatch? stopwatch,
    DateTime Function()? deviceNow,
  }) : _stopwatch = (stopwatch ?? Stopwatch())..start(),
       _deviceNow = deviceNow ?? DateTime.now;

  final Stopwatch _stopwatch;
  final DateTime Function() _deviceNow;

  /// Samples whose round trip took longer than this are too imprecise to use.
  static const Duration maxRoundTrip = Duration(seconds: 5);

  /// A better (lower-uncertainty) sample always replaces the anchor; a worse
  /// one only does once the current anchor is this old, so a long-running
  /// session still re-syncs occasionally.
  static const Duration anchorMaxAge = Duration(minutes: 10);

  /// `Date` headers are truncated to whole seconds, so the true server time
  /// lies somewhere in [date, date + 1 s); the midpoint is the best guess.
  static const Duration _headerResolutionMidpoint = Duration(milliseconds: 500);

  DateTime? _anchorServer;
  Duration _anchorElapsed = Duration.zero;
  Duration _anchorUncertainty = Duration.zero;

  /// A monotonic reading to timestamp a request's send and receive with,
  /// for [observe].
  Duration get monotonicNow => _stopwatch.elapsed;

  /// Whether at least one server-time sample has been accepted.
  bool get isSynced => _anchorServer != null;

  /// Server time minus device time right now, or null before the first
  /// sample. Diagnostic only — use [now] for arithmetic.
  Duration? get offset => isSynced ? now().difference(_deviceNow()) : null;

  /// Best estimate of the server's current time.
  DateTime now() {
    final anchor = _anchorServer;
    if (anchor == null) return _deviceNow();
    return anchor.add(_stopwatch.elapsed - _anchorElapsed);
  }

  /// Records a server timestamp from a response whose request was sent at
  /// [sentAt] and received at [receivedAt] (both [monotonicNow] readings).
  void observe({
    required DateTime serverDate,
    required Duration sentAt,
    required Duration receivedAt,
  }) {
    final roundTrip = receivedAt - sentAt;
    if (roundTrip.isNegative || roundTrip > maxRoundTrip) return;

    // The server stamped the response somewhere inside the round trip;
    // assume the middle, and widen the error bar by the header's 1 s
    // resolution.
    final halfTrip = roundTrip ~/ 2;
    final uncertainty = halfTrip + _headerResolutionMidpoint;

    if (_anchorServer != null) {
      final anchorAge = receivedAt - _anchorElapsed;
      if (uncertainty >= _anchorUncertainty && anchorAge < anchorMaxAge) return;
    }

    _anchorServer = serverDate.toUtc().add(
      _headerResolutionMidpoint + halfTrip,
    );
    _anchorElapsed = receivedAt;
    _anchorUncertainty = uncertainty;
  }
}
