import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mint_talk/app.dart';
import 'package:mint_talk/core/di/injection.dart';

void main() async {
  configureDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}
