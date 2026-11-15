import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/services/screen_capture/screen_capture_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('screen_protector');
  late List<String> calls;

  setUp(() {
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return true;
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Android', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);

    test('protects on first holder and unprotects after the last', () async {
      final guard = ScreenCaptureGuard();

      await guard.acquire('call_screen');
      await guard.acquire('live_call');
      expect(calls, ['preventScreenshotOn']);

      await guard.release('call_screen');
      expect(calls, ['preventScreenshotOn'], reason: 'live_call still holds');

      await guard.release('live_call');
      expect(calls, ['preventScreenshotOn', 'preventScreenshotOff']);
    });

    test('repeated acquire/release by one holder is idempotent', () async {
      final guard = ScreenCaptureGuard();

      await guard.acquire('call_screen');
      await guard.acquire('call_screen');
      await guard.release('call_screen');
      await guard.release('call_screen');
      await guard.release('unknown');

      expect(calls, ['preventScreenshotOn', 'preventScreenshotOff']);
    });

    test('rapid unawaited on/off/on settles protected, in order', () async {
      final guard = ScreenCaptureGuard();

      guard.acquire('a');
      guard.release('a');
      await guard.acquire('a');

      expect(calls, ['preventScreenshotOn']);
    });

    test('a platform failure is swallowed and retried next sync', () async {
      var fail = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            if (fail) throw PlatformException(code: 'boom');
            return true;
          });
      final guard = ScreenCaptureGuard();

      await guard.acquire('a');
      fail = false;
      await guard.acquire('b');

      expect(calls, ['preventScreenshotOn', 'preventScreenshotOn']);
    });
  });

  test('iOS also blocks screen recording', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final guard = ScreenCaptureGuard();

    await guard.acquire('call_screen');
    await guard.release('call_screen');

    expect(calls, [
      'preventScreenshotOn',
      'preventScreenRecordOn',
      'preventScreenshotOff',
      'preventScreenRecordOff',
    ]);
  });
}
