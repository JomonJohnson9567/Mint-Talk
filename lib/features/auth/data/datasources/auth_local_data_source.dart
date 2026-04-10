import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Local data source to securely store user-specific flags like OTP verification
/// and profile completion status.
@lazySingleton
class AuthLocalDataSource {
  static const _isOtpVerifiedKey = 'is_otp_verified';
  static const _isProfileCompletedKey = 'is_profile_completed';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  const AuthLocalDataSource();

  Future<void> saveIsOtpVerified(bool isVerified) async {
    await _secureStorage.write(
      key: _isOtpVerifiedKey,
      value: isVerified.toString(),
    );
  }

  Future<bool> getIsOtpVerified() async {
    final value = await _secureStorage.read(key: _isOtpVerifiedKey);
    return value == 'true';
  }

  Future<void> saveIsProfileCompleted(bool isCompleted) async {
    await _secureStorage.write(
      key: _isProfileCompletedKey,
      value: isCompleted.toString(),
    );
  }

  Future<bool> getIsProfileCompleted() async {
    final value = await _secureStorage.read(key: _isProfileCompletedKey);
    return value == 'true';
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _isOtpVerifiedKey);
    await _secureStorage.delete(key: _isProfileCompletedKey);
  }
}
