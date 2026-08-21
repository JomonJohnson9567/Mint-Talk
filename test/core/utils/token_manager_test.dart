import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

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
}
