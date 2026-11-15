import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/utils/server_clock.dart';

/// Monotonic time the test advances by hand.
class _FakeStopwatch implements Stopwatch {
  Duration value = Duration.zero;

  @override
  Duration get elapsed => value;

  @override
  void start() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeStopwatch stopwatch;
  late DateTime device;
  late ServerClock clock;

  setUp(() {
    stopwatch = _FakeStopwatch();
    device = DateTime.utc(2026, 11, 4, 15, 34, 0);
    clock = ServerClock.withSources(stopwatch: stopwatch, deviceNow: () => device);
  });

  void advance(Duration d) {
    stopwatch.value += d;
    device = device.add(d);
  }

  /// A response received "now" whose request took [roundTrip], carrying
  /// [serverDate] in its Date header.
  void sample(DateTime serverDate, {Duration roundTrip = Duration.zero}) {
    clock.observe(
      serverDate: serverDate,
      sentAt: stopwatch.value - roundTrip,
      receivedAt: stopwatch.value,
    );
  }

  test('falls back to the device clock until synced', () {
    expect(clock.isSynced, isFalse);
    expect(clock.offset, isNull);
    expect(clock.now(), device);
  });

  test('a device clock 90 s fast is corrected', () {
    final server = device.subtract(const Duration(seconds: 90));
    sample(server);

    expect(clock.isSynced, isTrue);
    // +500 ms: Date headers are truncated to the second.
    expect(clock.now(), server.add(const Duration(milliseconds: 500)));
    expect(clock.offset, const Duration(seconds: -89, milliseconds: -500));
  });

  test('accounts for half the round trip', () {
    final server = device.subtract(const Duration(seconds: 30));
    sample(server, roundTrip: const Duration(milliseconds: 400));

    expect(clock.now(), server.add(const Duration(milliseconds: 700)));
  });

  test('advances monotonically and ignores device clock changes after syncing', () {
    final server = device;
    sample(server);

    advance(const Duration(seconds: 10));
    device = device.add(const Duration(hours: 1)); // user edits the time

    expect(clock.now(), server.add(const Duration(seconds: 10, milliseconds: 500)));
  });

  test('a more precise sample replaces the anchor; a less precise one does not', () {
    final server = device.subtract(const Duration(seconds: 60));
    sample(server, roundTrip: const Duration(seconds: 2));
    final afterFirst = clock.now();

    // Worse (slower) sample with a different reading: ignored.
    sample(server.add(const Duration(seconds: 5)), roundTrip: const Duration(seconds: 3));
    expect(clock.now(), afterFirst);

    // Better sample: taken.
    sample(server, roundTrip: const Duration(milliseconds: 100));
    expect(clock.now(), server.add(const Duration(milliseconds: 550)));
  });

  test('a stale anchor is replaced even by a less precise sample', () {
    sample(device, roundTrip: Duration.zero);

    advance(ServerClock.anchorMaxAge);
    final resynced = device.subtract(const Duration(seconds: 20));
    sample(resynced, roundTrip: const Duration(seconds: 1));

    expect(clock.now(), resynced.add(const Duration(seconds: 1)));
  });

  test('samples with an implausible round trip are ignored', () {
    sample(
      device.subtract(const Duration(minutes: 5)),
      roundTrip: ServerClock.maxRoundTrip + const Duration(milliseconds: 1),
    );
    expect(clock.isSynced, isFalse);

    clock.observe(
      serverDate: device,
      sentAt: stopwatch.value + const Duration(seconds: 1),
      receivedAt: stopwatch.value,
    );
    expect(clock.isSynced, isFalse);
  });
}
