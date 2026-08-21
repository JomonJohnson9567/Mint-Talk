import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// A future crash-reporting/analytics vendor (Crashlytics, Sentry, ...) can
/// be added later as one more [LogOutput] here — e.g.
/// `MultiOutput([ConsoleOutput(), SentryLogOutput()])` — with zero changes
/// to the many call sites already using `appLogger.i/d/e/w(...)`.
///
/// `level` is gated behind [kDebugMode] so none of these calls print to the
/// OS console (logcat / Console.app) in release builds — request/response
/// bodies logged via this logger can contain tokens and PII, which must
/// never reach a release build's device log.
final appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
  ),
  output: MultiOutput([ConsoleOutput()]),
  level: kDebugMode ? Level.trace : Level.off,
);
