import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/di/injection.dart';

/// All API endpoint constants in one place.
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => getIt<EnvConfig>().baseUrl;

  // Health (outside /api/v1)
  static String get health => getIt<EnvConfig>().healthUrl;

  // ── Auth ──────────────────────────────────────────────────────────────
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // ── User / Profile ───────────────────────────────────────────────────
  static const String updateProfile = '/user/profile';
  static const String referralVerify = '/user/referral-verify';

  // ── Plans ─────────────────────────────────────────────────────────────
  static const String plans = '/plans';

  // ── Wallet ────────────────────────────────────────────────────────────
  static const String walletInitialize = '/wallet/initialize';
  static String walletBalance(String userId) => '/wallet/$userId/balance';
  static String rechargeHistory(String userId) =>
      '/wallet/$userId/recharge-history';
  static String referralStatus(String userId) =>
      '/wallet/$userId/referral-status';

  // ── Payments ──────────────────────────────────────────────────────────
  static const String createOrder = '/payments/create-order';
  static const String verifyPayment = '/payments/verify';
  // POst------
  static const String applyForHost = '/host-applications/apply';
  static const String verifyKYC = '/host-applications/kyc';
}
