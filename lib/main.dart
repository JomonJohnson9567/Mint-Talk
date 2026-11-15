import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mint_talk/app.dart';
import 'package:mint_talk/core/cubit/developer_mode_cubit.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/services/session/session_manager.dart';
import 'package:mint_talk/features/shared/block_users/data/host_visibility_sync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const env = String.fromEnvironment('ENV', defaultValue: 'dev');

  _validateRequiredEnvVars(env);

  configureDependencies(environment: env);
  getIt<SessionManager>().startMonitoring();
  getIt<HostVisibilitySync>().start();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Resolved before the first frame so a blocked device never flashes the
  // app (splash, auth, socket) before the Developer-options block appears.
  await getIt<DeveloperModeCubit>().check();

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
