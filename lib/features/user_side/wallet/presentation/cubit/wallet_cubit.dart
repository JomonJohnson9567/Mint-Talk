import 'dart:convert';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/constants/user_role.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/usecases/watch_new_notifications_usecase.dart';
import 'package:mint_talk/core/services/razorpay_service.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/create_order_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_plans_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_wallet_balance_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/initialize_wallet_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/verify_payment_usecase.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_data.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/payment_method.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

@injectable
class WalletCubit extends Cubit<WalletState> {
  final InitializeWalletUseCase initializeWalletUseCase;
  final GetWalletBalanceUseCase getWalletBalanceUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final GetPlansUseCase getPlansUseCase;
  final AuthRepository authRepository;
  final RazorpayService razorpayService;

  StreamSubscription<NotificationEntity>? _notificationSub;

  String? _lastTransactionId;

  /// Options of the checkout currently open, kept so it can be reopened
  /// without the method filter (see [_handlePaymentError]).
  Map<String, dynamic>? _lastCheckoutOptions;

  WalletCubit({
    required this.initializeWalletUseCase,
    required this.getWalletBalanceUseCase,
    required this.createOrderUseCase,
    required this.verifyPaymentUseCase,
    required this.getPlansUseCase,
    required this.authRepository,
    required this.razorpayService,
    WatchNewNotificationsUseCase? watchNewNotificationsUseCase,
  }) : super(const WalletState(status: WalletStatus.initial)) {
    _initRazorpay();
    // A recharge confirmed/failed server-side (e.g. webhook after the app
    // lost the Razorpay callback) changes the balance — refetch it.
    _notificationSub = watchNewNotificationsUseCase?.call().listen((n) {
      final text = '${n.type} ${n.title}'.toLowerCase();
      if (!isClosed &&
          state.status != WalletStatus.initial &&
          text.contains('recharge')) {
        fetchBalance();
      }
    });
  }

  void _initRazorpay() {
    razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }

  @override
  Future<void> close() {
    _notificationSub?.cancel();
    razorpayService.dispose();
    return super.close();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    appLogger.i('WalletCubit: Success - Payment ID: ${response.paymentId}');

    final transactionId = _lastTransactionId;
    final orderId = response.orderId;

    if (transactionId == null || orderId == null) {
      emit(
        state.copyWith(
          status: WalletStatus.paymentFailure,
          errorMessage: 'Payment data mismatch. Please contact support.',
        ),
      );
      return;
    }

    verifyRecharge(
      razorpayOrderId: orderId,
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
      transactionId: transactionId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    appLogger.e(
      'WalletCubit: Error - Code: ${response.code}, Message: ${response.message}',
    );

    final error = _RazorpayError.parse(response.code, response.message);

    // The chosen method isn't available on this Razorpay account/mode, so the
    // method filter left checkout with nothing to show. Reopen the same order
    // once without the filter, preselecting the method instead.
    final options = _lastCheckoutOptions;
    if (error.isNoPaymentMethods &&
        options != null &&
        options.containsKey('config')) {
      appLogger.w(
        'WalletCubit: method filter left no payment methods; '
        'reopening checkout without it',
      );
      final fallback = Map<String, dynamic>.of(options)..remove('config');
      _lastCheckoutOptions = fallback;
      razorpayService.open(fallback);
      return;
    }

    emit(
      state.copyWith(
        status: WalletStatus.paymentFailure,
        errorMessage: error.userMessage,
      ),
    );
  }

  Future<void> fetchBalance() async {
    if (state.status == WalletStatus.loading) return;

    final role = await authRepository.getRole();
    if (role.toUserRole() == UserRole.host) {
      return;
    }

    final userId = await authRepository.getUserId();
    if (userId == null) {
      emit(
        state.copyWith(
          status: WalletStatus.error,
          errorMessage: 'User not logged in',
        ),
      );
      return;
    }

    emit(state.copyWith(status: WalletStatus.loading));
    final result = await getWalletBalanceUseCase(userId);
    await result.fold(
      (failure) async {
        if (_isWalletNotFound(failure)) {
          appLogger.i(
            'WalletCubit: Wallet not found for user $userId. Initializing...',
          );
          final initResult = await initializeWalletUseCase();
          initResult.fold(
            (initFailure) => emit(
              state.copyWith(
                status: WalletStatus.error,
                errorMessage: initFailure.message,
              ),
            ),
            (wallet) => emit(
              state.copyWith(
                status: WalletStatus.loaded,
                balance: wallet.balance,
              ),
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: WalletStatus.error,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (wallet) async => emit(
        state.copyWith(status: WalletStatus.loaded, balance: wallet.balance),
      ),
    );
  }

  Future<void> fetchPlans() async {
    emit(state.copyWith(status: WalletStatus.plansLoading));

    final result = await getPlansUseCase(NoParams());

    // The static catalogue is only a fallback for when the API fails or has
    // no plans — it is never mixed into a real API response.
    final plans = result.fold(
      (failure) => _fallbackPlans(),
      (apiPlans) => apiPlans.isEmpty ? _fallbackPlans() : [...apiPlans],
    )..sort((a, b) => a.numericPrice.compareTo(b.numericPrice));

    emit(state.copyWith(status: WalletStatus.plansLoaded, plans: plans));
  }

  List<RechargePlanEntity> _fallbackPlans() =>
      RechargePlanData.sections.expand((section) => section.plans).toList();

  /// A 404 on wallet lookup means the user has no wallet yet — the message
  /// check is a defensive fallback in case a backend path returns a
  /// different status code for the same "not found" condition.
  bool _isWalletNotFound(Failure failure) =>
      failure.statusCode == 404 || failure.message.contains('Wallet not found');

  /// Plan of the recharge currently in flight, so the screen that started it
  /// can show the coins added on success.
  String? get pendingPlanId => _pendingPlanId;
  String? _pendingPlanId;

  /// Creates the order and opens Razorpay checkout. With a [method], checkout
  /// shows only that method; without one, it shows every method Razorpay
  /// offers (UPI, cards, net banking, wallets…).
  Future<void> startRecharge(String planId, {PaymentMethod? method}) async {
    // Ignore repeat taps while an order is being created or verified.
    if (state.status == WalletStatus.paymentProcessing) return;
    _pendingPlanId = planId;
    emit(state.copyWith(status: WalletStatus.paymentProcessing));
    final result = await createOrderUseCase(planId);
    // Prefilled so checkout doesn't ask for the number the user logged in with.
    final phone = await authRepository.getPhone();
    final methodName = method == null ? null : _razorpayMethodName(method);
    final displayConfig = method == null
        ? null
        : _checkoutDisplayConfig(method);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: WalletStatus.paymentFailure,
          errorMessage: failure.message,
        ),
      ),
      (order) {
        _lastTransactionId = order.transactionId;

        // Emit specific state to trigger UI to open Razorpay
        emit(
          state.copyWith(
            status: WalletStatus.orderCreated,
            orderId: order.orderId,
            amount: order.amount,
            key: order.key,
            transactionId: order.transactionId,
          ),
        );

        // Now open the checkout using the service
        final options = <String, dynamic>{
          'key': order.key,
          'amount': order.amount,
          'name': AppTexts.appName,
          'order_id': order.orderId,
          'description': 'Recharge',
          'timeout': 300,
          'prefill': {
            if (phone != null && phone.trim().isNotEmpty)
              'contact': phone.trim(),
            'email': '',
            // Preselects the method; also what the no-filter fallback keeps.
            'method': ?methodName,
          },
          'config': ?displayConfig,
        };

        _lastCheckoutOptions = options;
        razorpayService.open(options);
      },
    );
  }

  static String _razorpayMethodName(PaymentMethod method) => switch (method) {
    PaymentMethod.upi => 'upi',
    PaymentMethod.card => 'card',
    PaymentMethod.netbanking => 'netbanking',
  };

  /// Razorpay `config.display` that shows a single block holding only
  /// [method], with Checkout's default blocks hidden.
  static Map<String, dynamic> _checkoutDisplayConfig(PaymentMethod method) {
    final razorpayMethod = _razorpayMethodName(method);
    final label = switch (method) {
      PaymentMethod.upi => 'Pay via UPI',
      PaymentMethod.card => 'Pay by card',
      PaymentMethod.netbanking => 'Pay via net banking',
    };

    return {
      'display': {
        'blocks': {
          'selected': {
            'name': label,
            'instruments': [
              {'method': razorpayMethod},
            ],
          },
        },
        'sequence': ['block.selected'],
        'preferences': {'show_default_blocks': false},
      },
    };
  }

  Future<void> verifyRecharge({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String transactionId,
  }) async {
    emit(state.copyWith(status: WalletStatus.paymentProcessing));
    final result = await verifyPaymentUseCase(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
      transactionId: transactionId,
    );

    await result.fold(
      (failure) async => emit(
        state.copyWith(
          status: WalletStatus.paymentFailure,
          errorMessage: failure.message,
        ),
      ),
      (verifiedBalance) async {
        // The balance parsed out of the verify-payment response can be
        // stale or missing depending on the backend's response shape, so
        // re-fetch from the wallet endpoint (the same source fetchBalance()
        // uses) and only fall back to the verify response if that fails.
        var balance = verifiedBalance;
        final userId = await authRepository.getUserId();
        if (userId != null) {
          final balanceResult = await getWalletBalanceUseCase(userId);
          balanceResult.fold(
            (failure) => appLogger.w(
              'WalletCubit: Post-payment balance refresh failed, using verify response balance. ${failure.message}',
            ),
            (wallet) => balance = wallet.balance,
          );
        }

        emit(
          state.copyWith(status: WalletStatus.paymentSuccess, balance: balance),
        );
        // Also emit loaded state to update UI
        emit(state.copyWith(status: WalletStatus.loaded, balance: balance));
      },
    );
  }
}

/// A Razorpay checkout error. The SDK's `message` is often a raw JSON string
/// (`{"error":{"description":…,"reason":…}}`), which must not reach the UI.
class _RazorpayError {
  const _RazorpayError({required this.userMessage, this.reason});

  final String userMessage;
  final String? reason;

  bool get isNoPaymentMethods => reason == 'no_payment_methods';

  factory _RazorpayError.parse(int? code, String? message) {
    String? description;
    String? reason;
    try {
      final decoded = jsonDecode(message ?? '');
      final error = decoded is Map ? decoded['error'] : null;
      if (error is Map) {
        description = error['description']?.toString();
        reason = error['reason']?.toString();
      }
    } on FormatException {
      // Plain-text message — used as-is below.
    }

    if (reason == 'no_payment_methods') {
      return _RazorpayError(
        reason: reason,
        userMessage:
            'This payment method isn\'t available right now. '
            'Please try another one.',
      );
    }
    if (code == Razorpay.PAYMENT_CANCELLED) {
      return const _RazorpayError(userMessage: 'Payment cancelled');
    }

    final text = description ?? message;
    final isReadable =
        text != null &&
        text.trim().isNotEmpty &&
        !text.trimLeft().startsWith('{');
    return _RazorpayError(
      reason: reason,
      userMessage: isReadable ? text : 'Payment failed. Please try again.',
    );
  }
}
