import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/cubit/app_update_cubit.dart';
import 'package:mint_talk/core/services/app_update/i_app_update_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppUpdateService extends Mock implements IAppUpdateService {}

const _available = AppUpdateCheck(
  availability: AppUpdateAvailability.available,
  flexibleAllowed: true,
  availableVersionCode: 3,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAppUpdateService service;
  late StreamController<void> downloadStarted;
  late AppUpdateCubit cubit;

  setUp(() {
    service = _MockAppUpdateService();
    downloadStarted = StreamController<void>.broadcast();
    when(() => service.downloadStarted).thenAnswer((_) => downloadStarted.stream);
    when(() => service.completeFlexibleUpdate()).thenAnswer((_) async {});
    when(() => service.openStoreListing()).thenAnswer((_) async {});
    cubit = AppUpdateCubit(service);
  });

  tearDown(() async {
    await cubit.close();
    await downloadStarted.close();
  });

  test('no update → stays idle', () async {
    when(() => service.checkForUpdate())
        .thenAnswer((_) async => AppUpdateCheck.none);
    await cubit.checkForUpdate();
    expect(cubit.state.status, AppUpdateStatus.idle);
  });

  test('update available → available with version code', () async {
    when(() => service.checkForUpdate()).thenAnswer((_) async => _available);
    await cubit.checkForUpdate();
    expect(cubit.state.status, AppUpdateStatus.available);
    expect(cubit.state.flexibleAllowed, isTrue);
    expect(cubit.state.availableVersionCode, 3);
  });

  test('download finished in an earlier session → readyToInstall', () async {
    when(() => service.checkForUpdate()).thenAnswer(
      (_) async =>
          const AppUpdateCheck(availability: AppUpdateAvailability.downloaded),
    );
    await cubit.checkForUpdate();
    expect(cubit.state.status, AppUpdateStatus.readyToInstall);
  });

  test('"Later" → idle and not re-prompted for the rest of the session',
      () async {
    when(() => service.checkForUpdate()).thenAnswer((_) async => _available);
    await cubit.checkForUpdate();
    cubit.dismiss();
    expect(cubit.state.status, AppUpdateStatus.idle);
    expect(cubit.state.dismissed, isTrue);

    await cubit.checkForUpdate();
    expect(cubit.state.status, AppUpdateStatus.idle);
  });

  test('"Update" → downloading → readyToInstall → installNow', () async {
    when(() => service.checkForUpdate()).thenAnswer((_) async => _available);
    final download = Completer<bool>();
    when(() => service.startFlexibleUpdate())
        .thenAnswer((_) => download.future);
    await cubit.checkForUpdate();

    final updating = cubit.startUpdate();
    await Future<void>.delayed(Duration.zero);
    downloadStarted.add(null);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.status, AppUpdateStatus.downloading);

    download.complete(true);
    await updating;
    expect(cubit.state.status, AppUpdateStatus.readyToInstall);

    await cubit.installNow();
    verify(() => service.completeFlexibleUpdate()).called(1);
  });

  test('declining Play\'s dialog → idle and dismissed', () async {
    when(() => service.checkForUpdate()).thenAnswer((_) async => _available);
    when(() => service.startFlexibleUpdate()).thenAnswer((_) async => false);
    await cubit.checkForUpdate();
    await cubit.startUpdate();
    expect(cubit.state.status, AppUpdateStatus.idle);
    expect(cubit.state.dismissed, isTrue);
  });

  test('flexible update not allowed → opens the store listing', () async {
    when(() => service.checkForUpdate()).thenAnswer(
      (_) async => const AppUpdateCheck(
        availability: AppUpdateAvailability.available,
        flexibleAllowed: false,
      ),
    );
    await cubit.checkForUpdate();
    await cubit.startUpdate();
    verify(() => service.openStoreListing()).called(1);
    verifyNever(() => service.startFlexibleUpdate());
    expect(cubit.state.status, AppUpdateStatus.idle);
  });

  test('resume before the first check does not check', () {
    cubit.didChangeAppLifecycleState(AppLifecycleState.resumed);
    verifyNever(() => service.checkForUpdate());
  });

  test('resume shortly after a check does not re-check', () async {
    when(() => service.checkForUpdate())
        .thenAnswer((_) async => AppUpdateCheck.none);
    await cubit.checkForUpdate();
    cubit.didChangeAppLifecycleState(AppLifecycleState.resumed);
    verify(() => service.checkForUpdate()).called(1);
  });
}
