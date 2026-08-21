import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mint_talk/app.dart';
import 'package:mint_talk/core/di/injection.dart';
// ignore: unused_import
import 'package:screen_protector/screen_protector.dart'; // re-needed once re-enabled below

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  _validateRequiredEnvVars(env);

  configureDependencies(environment: env);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // TODO(security): screenshot restriction temporarily disabled for testing.
  // Re-enable before any release build — see ScreenProtector.preventScreenshotOn().
  // await ScreenProtector.preventScreenshotOn();

  runApp(const MyApp());
}

void _validateRequiredEnvVars(String env) {
  const baseUrl = String.fromEnvironment('BASE_URL');
  const socketUrl = String.fromEnvironment('SOCKET_URL');
  final missing = [
    if (baseUrl.isEmpty) 'BASE_URL',
    if (socketUrl.isEmpty) 'SOCKET_URL',
  ];
  if (missing.isNotEmpty) {
    throw StateError(
      'Missing required env var(s) ${missing.join(', ')} for environment "$env". '
      'Build/run with --dart-define-from-file=env/$env.json (see env/example.json).',
    );
  }
}
