import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformUtils {
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isWeb => kIsWeb;

  static T select<T>({
    required T android,
    required T ios,
    T? web,
  }) {
    if (isWeb) return web ?? android;
    if (isIOS) return ios;
    return android;
  }
}
