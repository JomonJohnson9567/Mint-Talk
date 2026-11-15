import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/ring_window.dart';

void main() {
  final now = DateTime.utc(2026, 11, 10, 12);

  test('counts down to the server deadline', () {
    expect(
      RingWindow.remaining(now.add(const Duration(seconds: 18)), now),
      const Duration(seconds: 18),
    );
  });

  test('no deadline → fallback', () {
    expect(RingWindow.remaining(null, now), RingWindow.fallback);
    expect(
      RingWindow.remaining(null, now, fallback: const Duration(seconds: 7)),
      const Duration(seconds: 7),
    );
  });

  test('a passed deadline → zero', () {
    expect(
      RingWindow.remaining(now.subtract(const Duration(seconds: 1)), now),
      Duration.zero,
    );
  });

  test('an implausibly far deadline → fallback', () {
    expect(
      RingWindow.remaining(now.add(const Duration(minutes: 10)), now),
      RingWindow.fallback,
    );
  });

  test('timezone of the parsed value does not matter', () {
    final local = now.toLocal().add(const Duration(seconds: 30));
    expect(RingWindow.remaining(local, now), const Duration(seconds: 30));
  });
}
