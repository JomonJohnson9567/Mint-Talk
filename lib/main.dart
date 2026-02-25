import 'package:flutter/material.dart';
import 'package:mint_talk/app.dart';
import 'package:mint_talk/core/di/injection.dart';

void main() {
  configureDependencies();
  runApp(const MyApp());
}
