import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Registers [FlutterSecureStorage] in the DI container so dependents like
/// [TokenManager] can receive it via constructor injection instead of each
/// constructing their own `const FlutterSecureStorage()` inline.
@module
abstract class StorageModule {
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
