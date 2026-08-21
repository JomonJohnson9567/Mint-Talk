// Covers AuthRepositoryImpl.logout() only — the non-OTP method most at risk
// (session/token cleanup). sendOtp()/verifyOtp() are a deliberate testing
// stub and are intentionally out of scope for this suite.
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:mint_talk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRemoteDataSource extends Mock implements IAuthRemoteDataSource {}

class _MockAuthLocalDataSource extends Mock implements IAuthLocalDataSource {}

class _MockTokenManager extends Mock implements TokenManager {}

class _MockPresenceSocketService extends Mock implements IPresenceSocketService {}

void main() {
  late _MockAuthRemoteDataSource remoteDataSource;
  late _MockAuthLocalDataSource localDataSource;
  late _MockTokenManager tokenManager;
  late _MockPresenceSocketService presenceSocketService;
  late AuthRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _MockAuthRemoteDataSource();
    localDataSource = _MockAuthLocalDataSource();
    tokenManager = _MockTokenManager();
    presenceSocketService = _MockPresenceSocketService();
    repository = AuthRepositoryImpl(
      remoteDataSource,
      localDataSource,
      tokenManager,
      presenceSocketService,
    );

    when(() => tokenManager.clearAll()).thenAnswer((_) async {});
    when(() => localDataSource.clearAuthData()).thenAnswer((_) async {});
    when(() => presenceSocketService.disconnect()).thenReturn(null);
  });

  test('logout clears local session state even when the remote call succeeds', () async {
    when(() => remoteDataSource.logout()).thenAnswer((_) async {});

    final result = await repository.logout();

    expect(result.isRight(), isTrue);
    verify(() => tokenManager.clearAll()).called(1);
    verify(() => localDataSource.clearAuthData()).called(1);
    verify(() => presenceSocketService.disconnect()).called(1);
  });

  test('logout still clears local session state when the remote call throws', () async {
    when(() => remoteDataSource.logout()).thenThrow(Exception('offline'));

    final result = await repository.logout();

    // Local cleanup must proceed unconditionally — a failed/offline remote
    // invalidation must never leave stale tokens/session data behind.
    expect(result.isRight(), isTrue);
    verify(() => tokenManager.clearAll()).called(1);
    verify(() => localDataSource.clearAuthData()).called(1);
    verify(() => presenceSocketService.disconnect()).called(1);
  });
}
