import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Local data source to securely store user-specific flags like OTP verification
/// and profile completion status.
abstract class IAuthLocalDataSource {
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveFullName(String? fullName);
  Future<String?> getFullName();
  Future<void> savePhone(String? phone);
  Future<String?> getPhone();
  Future<void> saveRole(String? role);
  Future<String?> getRole();
  Future<void> saveDob(String? dob);
  Future<String?> getDob();
  Future<void> saveGender(String? gender);
  Future<String?> getGender();
  Future<void> saveReferralCode(String? referralCode);
  Future<String?> getReferralCode();
  Future<void> saveProfileImagePath(String? path);
  Future<String?> getProfileImagePath();
  Future<void> saveAudioRate(int? rate);
  Future<int?> getAudioRate();
  Future<void> saveVideoRate(int? rate);
  Future<int?> getVideoRate();
  Future<void> saveIsAudioAllowed(bool? isAllowed);
  Future<bool?> getIsAudioAllowed();
  Future<void> saveIsVideoAllowed(bool? isAllowed);
  Future<bool?> getIsVideoAllowed();
  Future<void> saveTermsAcceptedAt(String? value);
  Future<String?> getTermsAcceptedAt();
  Future<void> saveIsOtpVerified(bool isVerified);
  Future<bool> getIsOtpVerified();
  Future<void> saveIsProfileCompleted(bool isCompleted);
  Future<bool> getIsProfileCompleted();
  Future<void> clearAuthData();
}

@LazySingleton(as: IAuthLocalDataSource)
class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  static const _isOtpVerifiedKey = 'is_otp_verified';
  static const _isProfileCompletedKey = 'is_profile_completed';
  static const _userIdKey = 'user_id';
  static const _fullNameKey = 'full_name';
  static const _phoneKey = 'phone';
  static const _dobKey = 'dob';
  static const _genderKey = 'gender';
  static const _referralCodeKey = 'referral_code';
  static const _profileImagePathKey = 'profile_image_path';
  static const _audioRateKey = 'audio_rate';
  static const _videoRateKey = 'video_rate';
  static const _isAudioAllowedKey = 'is_audio_allowed';
  static const _isVideoAllowedKey = 'is_video_allowed';
  static const _roleKey = 'role';
  static const _termsAcceptedAtKey = 'terms_accepted_at';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  const AuthLocalDataSourceImpl();

  @override
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  @override
  Future<String?> getUserId() async {
    return _secureStorage.read(key: _userIdKey);
  }

  @override
  Future<void> saveFullName(String? fullName) async {
    if (fullName == null || fullName.trim().isEmpty) return;
    await _secureStorage.write(key: _fullNameKey, value: fullName.trim());
  }

  @override
  Future<String?> getFullName() async {
    return _secureStorage.read(key: _fullNameKey);
  }

  @override
  Future<void> savePhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    await _secureStorage.write(key: _phoneKey, value: phone.trim());
  }

  @override
  Future<String?> getPhone() async {
    return _secureStorage.read(key: _phoneKey);
  }

  @override
  Future<void> saveRole(String? role) async {
    if (role == null || role.trim().isEmpty) return;
    await _secureStorage.write(key: _roleKey, value: role.trim());
  }

  @override
  Future<String?> getRole() async {
    return _secureStorage.read(key: _roleKey);
  }

  @override
  Future<void> saveDob(String? dob) async {
    if (dob == null || dob.trim().isEmpty) return;
    await _secureStorage.write(key: _dobKey, value: dob.trim());
  }

  @override
  Future<String?> getDob() async {
    return _secureStorage.read(key: _dobKey);
  }

  @override
  Future<void> saveGender(String? gender) async {
    if (gender == null || gender.trim().isEmpty) return;
    await _secureStorage.write(key: _genderKey, value: gender.trim());
  }

  @override
  Future<String?> getGender() async {
    return _secureStorage.read(key: _genderKey);
  }

  @override
  Future<void> saveReferralCode(String? referralCode) async {
    if (referralCode == null || referralCode.trim().isEmpty) {
      await _secureStorage.delete(key: _referralCodeKey);
      return;
    }
    await _secureStorage.write(
      key: _referralCodeKey,
      value: referralCode.trim(),
    );
  }

  @override
  Future<String?> getReferralCode() async {
    return _secureStorage.read(key: _referralCodeKey);
  }

  @override
  Future<void> saveProfileImagePath(String? path) async {
    if (path == null || path.trim().isEmpty) {
      await _secureStorage.delete(key: _profileImagePathKey);
      return;
    }
    await _secureStorage.write(key: _profileImagePathKey, value: path.trim());
  }

  @override
  Future<String?> getProfileImagePath() async {
    return _secureStorage.read(key: _profileImagePathKey);
  }

  @override
  Future<void> saveAudioRate(int? rate) async {
    if (rate == null) {
      await _secureStorage.delete(key: _audioRateKey);
      return;
    }
    await _secureStorage.write(key: _audioRateKey, value: rate.toString());
  }

  @override
  Future<int?> getAudioRate() async {
    final value = await _secureStorage.read(key: _audioRateKey);
    return int.tryParse(value ?? '');
  }

  @override
  Future<void> saveVideoRate(int? rate) async {
    if (rate == null) {
      await _secureStorage.delete(key: _videoRateKey);
      return;
    }
    await _secureStorage.write(key: _videoRateKey, value: rate.toString());
  }

  @override
  Future<int?> getVideoRate() async {
    final value = await _secureStorage.read(key: _videoRateKey);
    return int.tryParse(value ?? '');
  }

  @override
  Future<void> saveIsAudioAllowed(bool? isAllowed) async {
    if (isAllowed == null) {
      await _secureStorage.delete(key: _isAudioAllowedKey);
      return;
    }
    await _secureStorage.write(
      key: _isAudioAllowedKey,
      value: isAllowed.toString(),
    );
  }

  @override
  Future<bool?> getIsAudioAllowed() async {
    final value = await _secureStorage.read(key: _isAudioAllowedKey);
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

  @override
  Future<void> saveIsVideoAllowed(bool? isAllowed) async {
    if (isAllowed == null) {
      await _secureStorage.delete(key: _isVideoAllowedKey);
      return;
    }
    await _secureStorage.write(
      key: _isVideoAllowedKey,
      value: isAllowed.toString(),
    );
  }

  @override
  Future<bool?> getIsVideoAllowed() async {
    final value = await _secureStorage.read(key: _isVideoAllowedKey);
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

  @override
  Future<void> saveTermsAcceptedAt(String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _secureStorage.delete(key: _termsAcceptedAtKey);
      return;
    }
    await _secureStorage.write(key: _termsAcceptedAtKey, value: value.trim());
  }

  @override
  Future<String?> getTermsAcceptedAt() async {
    return _secureStorage.read(key: _termsAcceptedAtKey);
  }

  @override
  Future<void> saveIsOtpVerified(bool isVerified) async {
    await _secureStorage.write(
      key: _isOtpVerifiedKey,
      value: isVerified.toString(),
    );
  }

  @override
  Future<bool> getIsOtpVerified() async {
    final value = await _secureStorage.read(key: _isOtpVerifiedKey);
    return value == 'true';
  }

  @override
  Future<void> saveIsProfileCompleted(bool isCompleted) async {
    await _secureStorage.write(
      key: _isProfileCompletedKey,
      value: isCompleted.toString(),
    );
  }

  @override
  Future<bool> getIsProfileCompleted() async {
    final value = await _secureStorage.read(key: _isProfileCompletedKey);
    return value == 'true';
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _isOtpVerifiedKey);
    await _secureStorage.delete(key: _isProfileCompletedKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _fullNameKey);
    await _secureStorage.delete(key: _phoneKey);
    await _secureStorage.delete(key: _dobKey);
    await _secureStorage.delete(key: _genderKey);
    await _secureStorage.delete(key: _referralCodeKey);
    await _secureStorage.delete(key: _profileImagePathKey);
    await _secureStorage.delete(key: _audioRateKey);
    await _secureStorage.delete(key: _videoRateKey);
    await _secureStorage.delete(key: _isAudioAllowedKey);
    await _secureStorage.delete(key: _isVideoAllowedKey);
    await _secureStorage.delete(key: _roleKey);
    await _secureStorage.delete(key: _termsAcceptedAtKey);
  }
}
