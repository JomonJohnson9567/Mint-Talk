import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/cubit/developer_mode_cubit.dart';
import 'package:mint_talk/core/services/device_security/device_security_service.dart';
import 'package:mint_talk/core/services/device_security/i_device_security_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockDeviceSecurity extends Mock implements IDeviceSecurityService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceSecurityService', () {
    const channel = MethodChannel('com.minttalk.app/device_security');
    Object? nativeResult;

    setUp(() {
      nativeResult = true;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            final result = nativeResult;
            if (result is Exception) throw result;
            return result;
          });
    });

    tearDown(() {
      DeviceSecurityService.enforce = kReleaseMode;
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('reports the native value on enforced Android', () async {
      DeviceSecurityService.enforce = true;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(await DeviceSecurityService().isDeveloperModeEnabled(), isTrue);
    });

    test('never blocks when not enforced (debug/profile builds)', () async {
      DeviceSecurityService.enforce = false;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(await DeviceSecurityService().isDeveloperModeEnabled(), isFalse);
    });

    test('never blocks on iOS', () async {
      DeviceSecurityService.enforce = true;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(await DeviceSecurityService().isDeveloperModeEnabled(), isFalse);
    });

    test('fails open on a channel error', () async {
      DeviceSecurityService.enforce = true;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      nativeResult = PlatformException(code: 'boom');

      expect(await DeviceSecurityService().isDeveloperModeEnabled(), isFalse);
    });
  });

  group('DeveloperModeCubit', () {
    late _MockDeviceSecurity security;

    setUp(() => security = _MockDeviceSecurity());

    blocTest<DeveloperModeCubit, bool>(
      'check() blocks when developer mode is on',
      setUp: () => when(
        () => security.isDeveloperModeEnabled(),
      ).thenAnswer((_) async => true),
      build: () => DeveloperModeCubit(security),
      act: (cubit) => cubit.check(),
      expect: () => [true],
    );

    blocTest<DeveloperModeCubit, bool>(
      're-checks on resume and unblocks once turned off',
      setUp: () {
        final answers = [true, false];
        when(
          () => security.isDeveloperModeEnabled(),
        ).thenAnswer((_) async => answers.removeAt(0));
      },
      build: () => DeveloperModeCubit(security),
      act: (cubit) async {
        await cubit.check();
        cubit.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [true, false],
    );

    blocTest<DeveloperModeCubit, bool>(
      'ignores non-resume lifecycle changes',
      build: () => DeveloperModeCubit(security),
      act: (cubit) =>
          cubit.didChangeAppLifecycleState(AppLifecycleState.paused),
      expect: () => <bool>[],
      verify: (_) => verifyNever(() => security.isDeveloperModeEnabled()),
    );
  });
}
