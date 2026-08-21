import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';

@lazySingleton
class RazorpayService {
  final Razorpay _razorpay = Razorpay();

  void Function(PaymentSuccessResponse)? _onSuccess;
  void Function(PaymentFailureResponse)? _onError;
  void Function(ExternalWalletResponse)? _onExternal;

  bool _isInitialized = false;

  /// Initialize listeners (SAFE: clears previous listeners)
  void init({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    void Function(ExternalWalletResponse)? onExternal,
  }) {
    // 🔥 CRITICAL FIX: Clear old listeners
    _razorpay.clear();

    _onSuccess = onSuccess;
    _onError = onError;
    _onExternal = onExternal;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _isInitialized = true;

    appLogger.d("Razorpay initialized");
  }

  /// Open checkout
  void open(Map<String, dynamic> options) {
    if (!_isInitialized) {
      throw Exception("RazorpayService not initialized. Call init() first.");
    }

    appLogger.i("Opening Razorpay Checkout");
    _razorpay.open(options);

    // Debug helper
    Future.delayed(const Duration(seconds: 5), () {
      appLogger.d("Waiting for Razorpay callback...");
    });
  }

  /// Success handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    appLogger.i("PAYMENT SUCCESS\n"
        "PaymentId: ${response.paymentId}\n"
        "OrderId: ${response.orderId}");

    _onSuccess?.call(response);
  }

  /// Error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    appLogger.e("PAYMENT ERROR\n"
        "Code: ${response.code}\n"
        "Message: ${response.message}");

    _onError?.call(response);
  }

  /// External wallet handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    appLogger.i("EXTERNAL WALLET: ${response.walletName}");

    _onExternal?.call(response);
  }

  /// Dispose listeners
  void dispose() {
    appLogger.d("Clearing Razorpay listeners");
    _razorpay.clear();
    _isInitialized = false;
  }
}