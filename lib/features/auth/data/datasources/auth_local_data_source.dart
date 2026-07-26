import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Local data source to securely store user-specific flags like OTP verification
/// and profile completion status.
@lazySingleton
class AuthLocalDataSource {
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
  static const _favoriteHostIdsKey = 'favorite_host_ids';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  const AuthLocalDataSource();

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return _secureStorage.read(key: _userIdKey);
  }

  Future<void> saveFullName(String? fullName) async {
    if (fullName == null || fullName.trim().isEmpty) return;
    await _secureStorage.write(key: _fullNameKey, value: fullName.trim());
  }

  Future<String?> getFullName() async {
    return _secureStorage.read(key: _fullNameKey);
  }

  Future<void> savePhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    await _secureStorage.write(key: _phoneKey, value: phone.trim());
  }

  Future<String?> getPhone() async {
    return _secureStorage.read(key: _phoneKey);
  }

  Future<void> saveRole(String? role) async {
    if (role == null || role.trim().isEmpty) return;
    await _secureStorage.write(key: _roleKey, value: role.trim());
  }

  Future<String?> getRole() async {
    return _secureStorage.read(key: _roleKey);
  }

  Future<void> saveDob(String? dob) async {
    if (dob == null || dob.trim().isEmpty) return;
    await _secureStorage.write(key: _dobKey, value: dob.trim());
  }

  Future<String?> getDob() async {
    return _secureStorage.read(key: _dobKey);
  }

  Future<void> saveGender(String? gender) async {
    if (gender == null || gender.trim().isEmpty) return;
    await _secureStorage.write(key: _genderKey, value: gender.trim());
  }

  Future<String?> getGender() async {
    return _secureStorage.read(key: _genderKey);
  }

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

  Future<String?> getReferralCode() async {
    return _secureStorage.read(key: _referralCodeKey);
  }

  Future<void> saveProfileImagePath(String? path) async {
    if (path == null || path.trim().isEmpty) {
      await _secureStorage.delete(key: _profileImagePathKey);
      return;
    }
    await _secureStorage.write(key: _profileImagePathKey, value: path.trim());
  }

  Future<String?> getProfileImagePath() async {
    return _secureStorage.read(key: _profileImagePathKey);
  }

  Future<void> saveAudioRate(int? rate) async {
    if (rate == null) {
      await _secureStorage.delete(key: _audioRateKey);
      return;
    }
    await _secureStorage.write(key: _audioRateKey, value: rate.toString());
  }

  Future<int?> getAudioRate() async {
    final value = await _secureStorage.read(key: _audioRateKey);
    return int.tryParse(value ?? '');
  }

  Future<void> saveVideoRate(int? rate) async {
    if (rate == null) {
      await _secureStorage.delete(key: _videoRateKey);
      return;
    }
    await _secureStorage.write(key: _videoRateKey, value: rate.toString());
  }

  Future<int?> getVideoRate() async {
    final value = await _secureStorage.read(key: _videoRateKey);
    return int.tryParse(value ?? '');
  }

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

  Future<bool?> getIsAudioAllowed() async {
    final value = await _secureStorage.read(key: _isAudioAllowedKey);
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

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

  Future<bool?> getIsVideoAllowed() async {
    final value = await _secureStorage.read(key: _isVideoAllowedKey);
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => null,
    };
  }

  Future<void> saveTermsAcceptedAt(String? value) async {
    if (value == null || value.trim().isEmpty) {
      await _secureStorage.delete(key: _termsAcceptedAtKey);
      return;
    }
    await _secureStorage.write(key: _termsAcceptedAtKey, value: value.trim());
  }

  Future<String?> getTermsAcceptedAt() async {
    return _secureStorage.read(key: _termsAcceptedAtKey);
  }

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
    await _secureStorage.delete(key: _favoriteHostIdsKey);
  }

  // ── Favourite Host IDs ────────────────────────────────────────────────────

  /// Loads the persisted set of favourite host IDs.
  Future<Set<String>> getFavoriteHostIds() async {
    final raw = await _secureStorage.read(key: _favoriteHostIdsKey);
    if (raw == null || raw.trim().isEmpty) return {};
    return raw.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).toSet();
  }

  /// Persists the given set of favourite host IDs.
  Future<void> saveFavoriteHostIds(Set<String> ids) async {
    if (ids.isEmpty) {
      await _secureStorage.delete(key: _favoriteHostIdsKey);
      return;
    }
    await _secureStorage.write(key: _favoriteHostIdsKey, value: ids.join(','));
  }

  /// Toggles a host ID in the favourites set and persists the result.
  ///
  /// Returns the updated [Set<String>] after toggling.
  Future<Set<String>> toggleFavoriteHostId(String hostId) async {
    final ids = await getFavoriteHostIds();
    if (ids.contains(hostId)) {
      ids.remove(hostId);
    } else {
      ids.add(hostId);
    }
    await saveFavoriteHostIds(ids);
    return ids;
  }
}
