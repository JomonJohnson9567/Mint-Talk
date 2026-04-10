/// All API endpoint constants in one place.
/// Base URL: https://mint-talk-backend.onrender.com/api/v1
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl =
      'https://mint-talk-backend.onrender.com/api/v1';

  // Health (outside /api/v1)
  static const String health = 'https://mint-talk-backend.onrender.com/health';

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

  // ── Admin ─────────────────────────────────────────────────────────────
  static const String adminLogin = '/admin/admin-login';
  static const String createAdmin = '/admin/create-admin';
  static const String blockAdmin = '/admin/block-admin';
  static const String unblockAdmin = '/admin/unblock-admin';
  static const String getAllAdmins = '/admin/get-all-admins';
  static const String adminLogout = '/admin/logout';
  static const String adminRecharges = '/admin/recharges';
}
