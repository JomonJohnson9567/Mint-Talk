import 'package:injectable/injectable.dart';

const staging = Environment('staging');

abstract class EnvConfig {
  String get baseUrl;
  String get healthUrl;
  String get razorpayKey;
  String get socketUrl;
  String get agoraAppId;
}

// Values are compiled in via `--dart-define-from-file=env/<env>.json` (see
// lib/main.dart and env/example.json) rather than bundled as an asset, so a
// given build only ever contains the one environment's config, never all
// three. The `defaultValue`s below exist only so tooling that doesn't pass
// --dart-define-from-file (analyzer, plain `flutter test`) still resolves to
// something; they are never relied on for a real run/build.

@dev
@LazySingleton(as: EnvConfig)
class DevEnvConfig implements EnvConfig {
  @override
  String get baseUrl => const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://mint-talk-backend.onrender.com/api/v1',
      );

  @override
  String get healthUrl => const String.fromEnvironment(
        'HEALTH_URL',
        defaultValue: 'https://mint-talk-backend.onrender.com/health',
      );

  @override
  String get razorpayKey =>
      const String.fromEnvironment('RAZORPAY_KEY', defaultValue: '');

  @override
  String get socketUrl => const String.fromEnvironment(
        'SOCKET_URL',
        defaultValue: 'wss://mint-talk-backend.onrender.com',
      );

  @override
  String get agoraAppId => const String.fromEnvironment(
        'AGORA_APP_ID',
        defaultValue: 'replace_with_agora_app_id',
      );
}

@staging
@LazySingleton(as: EnvConfig)
class StagingEnvConfig implements EnvConfig {
  @override
  String get baseUrl => const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://staging-mint-talk-backend.onrender.com/api/v1',
      );

  @override
  String get healthUrl => const String.fromEnvironment(
        'HEALTH_URL',
        defaultValue: 'https://staging-mint-talk-backend.onrender.com/health',
      );

  @override
  String get razorpayKey =>
      const String.fromEnvironment('RAZORPAY_KEY', defaultValue: '');

  @override
  String get socketUrl => const String.fromEnvironment(
        'SOCKET_URL',
        defaultValue: 'wss://mint-talk-backend.onrender.com',
      );

  @override
  String get agoraAppId => const String.fromEnvironment(
        'AGORA_APP_ID',
        defaultValue: 'replace_with_agora_app_id',
      );
}

@prod
@LazySingleton(as: EnvConfig)
class ProdEnvConfig implements EnvConfig {
  @override
  String get baseUrl => const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://mint-talk-backend.onrender.com/api/v1',
      );

  @override
  String get healthUrl => const String.fromEnvironment(
        'HEALTH_URL',
        defaultValue: 'https://mint-talk-backend.onrender.com/health',
      );

  @override
  String get razorpayKey =>
      const String.fromEnvironment('RAZORPAY_KEY', defaultValue: '');

  @override
  String get socketUrl => const String.fromEnvironment(
        'SOCKET_URL',
        defaultValue: 'wss://mint-talk-backend.onrender.com',
      );

  @override
  String get agoraAppId => const String.fromEnvironment(
        'AGORA_APP_ID',
        defaultValue: 'replace_with_agora_app_id',
      );
}
