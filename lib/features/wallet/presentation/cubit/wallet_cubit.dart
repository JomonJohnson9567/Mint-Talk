import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/core/services/razorpay_service.dart';
import 'package:mint_talk/features/wallet/domain/usecases/create_order_usecase.dart';
import 'package:mint_talk/features/wallet/domain/usecases/get_plans_usecase.dart';
import 'package:mint_talk/features/wallet/domain/usecases/get_wallet_balance_usecase.dart';
import 'package:mint_talk/features/wallet/domain/usecases/initialize_wallet_usecase.dart';
import 'package:mint_talk/features/wallet/domain/usecases/verify_payment_usecase.dart';
import 'package:mint_talk/features/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_data.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

@injectable
class WalletCubit extends Cubit<WalletState> {
  final InitializeWalletUseCase initializeWalletUseCase;
  final GetWalletBalanceUseCase getWalletBalanceUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final VerifyPaymentUseCase verifyPaymentUseCase;
  final GetPlansUseCase getPlansUseCase;
  final AuthLocalDataSource authLocalDataSource;
  final RazorpayService razorpayService;

  String? _lastTransactionId;

  WalletCubit({
    required this.initializeWalletUseCase,
    required this.getWalletBalanceUseCase,
    required this.createOrderUseCase,
    required this.verifyPaymentUseCase,
    required this.getPlansUseCase,
    required this.authLocalDataSource,
    required this.razorpayService,
  }) : super(const WalletState(status: WalletStatus.initial)) {
    _initRazorpay();
  }

  void _initRazorpay() {
    razorpayService.init(
      onSuccess: _handlePaymentSuccess,
      onError: _handlePaymentError,
    );
  }

  @override
  Future<void> close() {
    razorpayService.dispose();
    return super.close();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // ignore: avoid_print
    print('WalletCubit: Success - Payment ID: ${response.paymentId}');
    
    final transactionId = _lastTransactionId;
    final orderId = response.orderId;

    if (transactionId == null || orderId == null) {
      emit(state.copyWith(
        status: WalletStatus.paymentFailure,
        errorMessage: 'Payment data mismatch. Please contact support.',
      ));
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
    // ignore: avoid_print
    print('WalletCubit: Error - Code: ${response.code}, Message: ${response.message}');
    emit(state.copyWith(
      status: WalletStatus.paymentFailure,
      errorMessage: response.message ?? 'Payment failed',
    ));
  }

  Future<void> fetchBalance() async {
    if (state.status == WalletStatus.loading) return;
    
    final userId = await authLocalDataSource.getUserId();
    if (userId == null) {
      emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: 'User not logged in',
      ));
      return;
    }

    emit(state.copyWith(status: WalletStatus.loading));
    final result = await getWalletBalanceUseCase(userId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.error,
        errorMessage: failure.message,
      )),
      (wallet) => emit(state.copyWith(
        status: WalletStatus.loaded,
        balance: wallet.balance,
      )),
    );
  }

  Future<void> fetchPlans() async {
    emit(state.copyWith(status: WalletStatus.plansLoading));

    // Get dummy plans for merging
    final List<RechargePlanItem> dummyPlans = [];
    for (var section in RechargePlanData.sections) {
      dummyPlans.addAll(section.plans);
    }

    final result = await getPlansUseCase(NoParams());

    result.fold(
      (failure) {
        // If API fails, show at least the dummy plans
        emit(state.copyWith(
          status: WalletStatus.plansLoaded,
          plans: dummyPlans,
        ));
      },
      (apiPlans) {
        // Merge API plans with dummy plans.
        // We put API plans first.
        final mergedPlans = [...apiPlans, ...dummyPlans];

        // Remove duplicates by ID just in case there's overlap
        final uniqueMap = <String, RechargePlanItem>{};
        for (var plan in mergedPlans) {
          uniqueMap[plan.id] = plan;
        }

        emit(state.copyWith(
          status: WalletStatus.plansLoaded,
          plans: uniqueMap.values.toList(),
        ));
      },
    );
  }

  Future<void> startRecharge(String planId) async {
    emit(state.copyWith(status: WalletStatus.paymentProcessing));
    final result = await createOrderUseCase(planId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.paymentFailure,
        errorMessage: failure.message,
      )),
      (order) {
        _lastTransactionId = order.transactionId;
        
        // Emit specific state to trigger UI to open Razorpay
        emit(state.copyWith(
          status: WalletStatus.orderCreated,
          orderId: order.orderId,
          amount: order.amount,
          key: order.key,
          transactionId: order.transactionId,
        ));
        
        // Now open the checkout using the service
        final options = {
          'key': order.key,
          'amount': order.amount,
          'name': 'Mint Talk',
          'order_id': order.orderId,
          'description': 'Recharge',
          'timeout': 300,
          'prefill': {
            'contact': '', // To be filled if user details are available centrally
            'email': '',
          }
        };
        
        razorpayService.open(options);
      },
    );
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

    result.fold(
      (failure) => emit(state.copyWith(
        status: WalletStatus.paymentFailure,
        errorMessage: failure.message,
      )),
      (newBalance) {
        emit(state.copyWith(
          status: WalletStatus.paymentSuccess,
          balance: newBalance,
        ));
        // Also emit loaded state to update UI
        emit(state.copyWith(
          status: WalletStatus.loaded,
          balance: newBalance,
        ));
      },
    );
  }
}
