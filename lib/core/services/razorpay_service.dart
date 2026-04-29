import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:injectable/injectable.dart';

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

    print("✅ Razorpay initialized");
  }

  /// Open checkout
  void open(Map<String, dynamic> options) {
    if (!_isInitialized) {
      throw Exception("RazorpayService not initialized. Call init() first.");
    }

    print("🚀 Opening Razorpay Checkout");
    _razorpay.open(options);

    // Debug helper
    Future.delayed(const Duration(seconds: 5), () {
      print("⏳ Waiting for Razorpay callback...");
    });
  }

  /// Success handler
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("✅ PAYMENT SUCCESS");
    print("PaymentId: ${response.paymentId}");
    print("OrderId: ${response.orderId}");
    print("Signature: ${response.signature}");

    _onSuccess?.call(response);
  }

  /// Error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ PAYMENT ERROR");
    print("Code: ${response.code}");
    print("Message: ${response.message}");

    _onError?.call(response);
  }

  /// External wallet handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("💳 EXTERNAL WALLET: ${response.walletName}");

    _onExternal?.call(response);
  }

  /// Dispose listeners
  void dispose() {
    print("🧹 Clearing Razorpay listeners");
    _razorpay.clear();
    _isInitialized = false;
  }
}