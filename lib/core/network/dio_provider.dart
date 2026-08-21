import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/network/interceptors/auth_interceptor.dart';
import 'package:mint_talk/core/network/interceptors/error_interceptor.dart';
import 'package:mint_talk/core/network/interceptors/logger_interceptor.dart';
import 'package:mint_talk/core/network/pinned_certificates.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(dio),
      LoggerInterceptor(),
      ErrorInterceptor(),
    ]);

    _applyCertificatePinning(dio);

    return dio;
  }

  /// Pins the backend's TLS certificate in release builds only, so local/
  /// staging development isn't affected by a cert that doesn't match the
  /// pin yet. No-ops until [pinnedCertificateSha256Fingerprints] is
  /// populated with the real backend fingerprint.
  void _applyCertificatePinning(Dio dio) {
    if (!kReleaseMode || pinnedCertificateSha256Fingerprints.isEmpty) return;

    final adapter = IOHttpClientAdapter();
    adapter.createHttpClient = () {
      // `withTrustedRoots: false` disables the OS's default CA trust store,
      // so every connection (even one with an otherwise perfectly valid,
      // CA-signed certificate) fails default validation and is routed
      // through `badCertificateCallback` below — that callback is the only
      // place a certificate gets accepted, and it accepts one only if its
      // fingerprint is in the pinned allow-list. Without this, dart:io only
      // invokes `badCertificateCallback` for certs that are already
      // untrusted, which would make pinning a no-op against a normal
      // CA-signed MITM certificate.
      final client = HttpClient(
        context: SecurityContext(withTrustedRoots: false),
      );
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        final fingerprint = sha256.convert(cert.der).toString();
        return pinnedCertificateSha256Fingerprints.contains(fingerprint);
      };
      return client;
    };
    dio.httpClientAdapter = adapter;
  }
}
