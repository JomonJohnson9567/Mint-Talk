import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';

abstract class HostApplicationLocalDataSource {
  Future<bool> hasAcceptedTerms();
  Future<void> acceptTerms();
  Future<bool> hasSubmittedApplication();
  Future<void> markApplicationSubmitted();
}

@LazySingleton(as: HostApplicationLocalDataSource)
class HostApplicationLocalDataSourceImpl
    implements HostApplicationLocalDataSource {
  static const _termsAcceptedKey = 'host_terms_accepted_v1';
  static const _applicationSubmittedKey = 'host_application_submitted';

  final FlutterSecureStorage _storage;
  final IAuthLocalDataSource _authLocalDataSource;

  HostApplicationLocalDataSourceImpl(this._authLocalDataSource)
    : _storage = const FlutterSecureStorage();

  Future<String> _key(String baseKey) async {
    final userId = await _authLocalDataSource.getUserId();
    return userId == null || userId.isEmpty ? baseKey : '${baseKey}_$userId';
  }

  @override
  Future<bool> hasAcceptedTerms() async =>
      await _storage.read(key: await _key(_termsAcceptedKey)) == 'true';

  @override
  Future<void> acceptTerms() async =>
      _storage.write(key: await _key(_termsAcceptedKey), value: 'true');

  @override
  Future<bool> hasSubmittedApplication() async =>
      await _storage.read(key: await _key(_applicationSubmittedKey)) == 'true';

  @override
  Future<void> markApplicationSubmitted() async =>
      _storage.write(key: await _key(_applicationSubmittedKey), value: 'true');
}
