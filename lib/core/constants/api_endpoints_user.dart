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
  static String planById(String planId) => '/plans/$planId';

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
  static const String hostApplicationStatus = '/host-applications/my-status';

  // ── Host ─────────────────────────────────────────────────────────────
  static const String hostMyEarningsLedger = '/earnings/my-ledger';
  static const String hostWithdrawalsRequest = '/withdrawals/request';
  static const String hostWithdrawalsMyRequests = '/withdrawals/my-requests';
  static const String hostLeavesRequest = '/leaves/request';
  static const String hostLeavesMyRequests = '/leaves/my-requests';
  static const String hostPreferences = '/hosts/preferences';
  static const String hostMyTargets = '/hosts/my-targets';

  // ── Favorites ────────────────────────────────────────────────────────
  static const String userFavorites = '/user/favorites';
  static String userFavoriteHost(String hostId) => '/user/favorites/$hostId';

  // ── Block Users ───────────────────────────────────────────────────────
  static const String blockedList = '/user/blocked-list';
  static const String blockUser = '/user/block';
  static const String unblockUser = '/user/unblock';

  // ── Call Logs & Reports ────────────────────────────────────────────────
  static const String userCallLogs = '/calls/user-logs';
  static const String hostCallLogs = '/calls/host-logs';
  static const String callReportSummary = '/calls/report';
  static String reportCall(String callId) => '/calls/$callId/report';

  // ── Profile Image ──────────────────────────────────────────────────────
  /// POST multipart/form-data — field: "image" (max 5MB, JPEG/PNG/GIF/WEBP)
  /// Docs: POST /api/v1/user/profile-image  (alias: /api/v1/user/avatar)
  /// Backend currently serves the route at /user/avatar
  static const String profileImage = '/user/avatar';

  // ── Hosts ─────────────────────────────────────────────────────────────
  static const String hosts = '/hosts';
  static const String hostsOnline = '/hosts/online';
  static const String hostsOffline = '/hosts/offline';
  static const String hostsOnCall = '/hosts/on-call';

  // ── Notifications ────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';

  // ── Chat ─────────────────────────────────────────────────────────────
  static const String chatSendMessage = '/chats/messages';
  static const String chatConversations = '/chats/conversations';
  static String chatConversationMessages(String conversationId) =>
      '/chats/conversations/$conversationId/messages';
  static String chatConversationRead(String conversationId) =>
      '/chats/conversations/$conversationId/read';
  static const String chatMessagesDelivered = '/chats/messages/delivered';
  static const String chatPredefinedMessages = '/chats/predefined-messages';
}
