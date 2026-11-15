import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

/// Answers every request with a fixed status/body/headers, or throws
/// [error] to simulate a transport failure.
class _StubAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> body;
  final Map<String, List<String>> headers;
  final DioException Function(RequestOptions)? error;

  _StubAdapter({
    this.statusCode = 200,
    this.body = const {},
    this.headers = const {},
    this.error,
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (error != null) throw error!(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _MockSecureStorage secureStorage;
  late TokenManager tokenManager;

  setUp(() {
    secureStorage = _MockSecureStorage();
    tokenManager = TokenManager(secureStorage: secureStorage);
  });

  group('access token (in-memory)', () {
    test('is null until saved', () {
      expect(tokenManager.getAccessToken(), isNull);
    });

    test('saveAccessToken makes it retrievable without touching secure storage', () {
      tokenManager.saveAccessToken('access-123');

      expect(tokenManager.getAccessToken(), 'access-123');
      verifyZeroInteractions(secureStorage);
    });
  });

  group('refresh token (secure storage)', () {
    test('saveRefreshToken writes to secure storage under the expected key', () async {
      when(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});

      await tokenManager.saveRefreshToken('refresh-abc');

      verify(() => secureStorage.write(key: 'refresh_token', value: 'refresh-abc')).called(1);
    });

    test('getRefreshToken reads from secure storage under the expected key', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => 'refresh-abc');

      final result = await tokenManager.getRefreshToken();

      expect(result, 'refresh-abc');
      verify(() => secureStorage.read(key: 'refresh_token')).called(1);
    });

    test('hasRefreshToken is false when no token stored', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

      expect(await tokenManager.hasRefreshToken(), isFalse);
    });

    test('hasRefreshToken is false for an empty string token', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => '');

      expect(await tokenManager.hasRefreshToken(), isFalse);
    });

    test('hasRefreshToken is true when a non-empty token is stored', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => 'refresh-abc');

      expect(await tokenManager.hasRefreshToken(), isTrue);
    });
  });

  group('clearAll', () {
    test('clears the in-memory access token and deletes the stored refresh token', () async {
      tokenManager.saveAccessToken('access-123');
      when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});

      await tokenManager.clearAll();

      expect(tokenManager.getAccessToken(), isNull);
      verify(() => secureStorage.delete(key: 'refresh_token')).called(1);
    });
  });

  group('getValidAccessToken', () {
    test('returns the in-memory access token without attempting a refresh', () async {
      tokenManager.saveAccessToken('access-123');

      final result = await tokenManager.getValidAccessToken();

      expect(result, 'access-123');
      verifyZeroInteractions(secureStorage);
    });

    test('returns null when no access token and no refresh token exist', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);

      final result = await tokenManager.getValidAccessToken();

      expect(result, isNull);
    });
  });

  group('refreshAccessToken', () {
    void stubTransport(_StubAdapter adapter) {
      tokenManager.refreshDioFactory = () =>
          Dio(BaseOptions(baseUrl: 'https://example.test'))
            ..httpClientAdapter = adapter;
    }

    setUp(() {
      when(() => secureStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => 'refresh-old');
      when(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
    });

    test('success saves the new access token', () async {
      stubTransport(_StubAdapter(body: {'success': true, 'accessToken': 'access-new'}));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.success);
      expect(tokenManager.getAccessToken(), 'access-new');
      verifyNever(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value')));
    });

    test('success stores a rotated refresh token from Set-Cookie', () async {
      stubTransport(_StubAdapter(
        body: {'success': true, 'accessToken': 'access-new'},
        headers: {
          'set-cookie': ['refreshToken=refresh-rotated; Path=/; HttpOnly'],
        },
      ));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.success);
      verify(() => secureStorage.write(key: 'refresh_token', value: 'refresh-rotated')).called(1);
    });

    test('success stores a rotated refresh token from the response body', () async {
      stubTransport(_StubAdapter(body: {
        'success': true,
        'accessToken': 'access-new',
        'refreshToken': 'refresh-rotated',
      }));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.success);
      verify(() => secureStorage.write(key: 'refresh_token', value: 'refresh-rotated')).called(1);
    });

    test('403 (session revoked by another login) is rejected', () async {
      stubTransport(_StubAdapter(statusCode: 403, body: {'success': false}));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.rejected);
    });

    test('401 (expired refresh token) is rejected', () async {
      stubTransport(_StubAdapter(statusCode: 401, body: {'success': false}));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.rejected);
    });

    test('no stored refresh token is rejected without a request', () async {
      when(() => secureStorage.read(key: any(named: 'key'))).thenAnswer((_) async => null);
      stubTransport(_StubAdapter(
        error: (o) => throw StateError('refresh must not hit the network'),
      ));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.rejected);
    });

    test('a 5xx is transient, not a logout', () async {
      stubTransport(_StubAdapter(statusCode: 503, body: {'success': false}));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.transientFailure);
    });

    test('no network is transient, not a logout', () async {
      stubTransport(_StubAdapter(
        error: (o) => DioException.connectionError(
          requestOptions: o,
          reason: 'Failed host lookup',
        ),
      ));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.transientFailure);
    });

    test('a timeout is transient, not a logout', () async {
      stubTransport(_StubAdapter(
        error: (o) => DioException.receiveTimeout(
          timeout: const Duration(seconds: 60),
          requestOptions: o,
        ),
      ));

      expect(await tokenManager.refreshAccessToken(), RefreshResult.transientFailure);
    });
  });

  group('extractRefreshTokenFromSetCookie', () {
    test('finds the token among several cookies and headers', () {
      expect(
        extractRefreshTokenFromSetCookie([
          'csrf=abc; Path=/',
          'session=x; Path=/, refreshToken=tok-1; HttpOnly',
        ]),
        'tok-1',
      );
    });

    test('returns null when absent or empty', () {
      expect(extractRefreshTokenFromSetCookie(null), isNull);
      expect(extractRefreshTokenFromSetCookie(['refreshToken=; Path=/']), isNull);
    });
  });

  group('extractRefreshTokenFromBody', () {
    test('reads a non-empty refreshToken string', () {
      expect(extractRefreshTokenFromBody({'refreshToken': 'tok-1'}), 'tok-1');
    });

    test('returns null when absent, empty, or not a map', () {
      expect(extractRefreshTokenFromBody({'success': true}), isNull);
      expect(extractRefreshTokenFromBody({'refreshToken': ''}), isNull);
      expect(extractRefreshTokenFromBody('nope'), isNull);
    });
  });
}
