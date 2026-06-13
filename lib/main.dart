import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mint_talk/app.dart';
import 'package:mint_talk/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Resolve active environment (dev, staging, prod)
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  
  // Load environment-based config files (.env.dev, .env.staging, .env.prod)
  await dotenv.load(fileName: '.env.$env');
  
  configureDependencies(environment: env);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
