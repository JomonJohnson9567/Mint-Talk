// Regression test for the recharge/balance bug: verifyRecharge() must trust
// a fresh getWalletBalance() fetch over whatever balance the verify-payment
// response happened to parse out, since that response's shape/staleness is
// not fully controlled by this app.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/razorpay_service.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/wallet_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/create_order_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_plans_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_wallet_balance_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/initialize_wallet_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/verify_payment_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockInitializeWalletUseCase extends Mock implements InitializeWalletUseCase {}

class _MockGetWalletBalanceUseCase extends Mock implements GetWalletBalanceUseCase {}

class _MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}

class _MockVerifyPaymentUseCase extends Mock implements VerifyPaymentUseCase {}

class _MockGetPlansUseCase extends Mock implements GetPlansUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockRazorpayService extends Mock implements RazorpayService {}

void main() {
  late _MockInitializeWalletUseCase initializeWalletUseCase;
  late _MockGetWalletBalanceUseCase getWalletBalanceUseCase;
  late _MockCreateOrderUseCase createOrderUseCase;
  late _MockVerifyPaymentUseCase verifyPaymentUseCase;
  late _MockGetPlansUseCase getPlansUseCase;
  late _MockAuthRepository authRepository;
  late _MockRazorpayService razorpayService;
  late WalletCubit cubit;

  const userId = 'user-1';

  setUp(() {
    initializeWalletUseCase = _MockInitializeWalletUseCase();
    getWalletBalanceUseCase = _MockGetWalletBalanceUseCase();
    createOrderUseCase = _MockCreateOrderUseCase();
    verifyPaymentUseCase = _MockVerifyPaymentUseCase();
    getPlansUseCase = _MockGetPlansUseCase();
    authRepository = _MockAuthRepository();
    razorpayService = _MockRazorpayService();

    when(() => authRepository.getUserId()).thenAnswer((_) async => userId);

    cubit = WalletCubit(
      initializeWalletUseCase: initializeWalletUseCase,
      getWalletBalanceUseCase: getWalletBalanceUseCase,
      createOrderUseCase: createOrderUseCase,
      verifyPaymentUseCase: verifyPaymentUseCase,
      getPlansUseCase: getPlansUseCase,
      authRepository: authRepository,
      razorpayService: razorpayService,
    );
  });

  tearDown(() => cubit.close());

  group('verifyRecharge', () {
    test(
      'uses the freshly-fetched wallet balance, not the (possibly stale/incorrect) '
      'balance parsed out of the verify-payment response',
      () async {
        // Verify-payment response under-reports the balance (e.g. missing
        // wallet field in the response, or a webhook-timing race) ...
        when(() => verifyPaymentUseCase(
              razorpayOrderId: any(named: 'razorpayOrderId'),
              razorpayPaymentId: any(named: 'razorpayPaymentId'),
              razorpaySignature: any(named: 'razorpaySignature'),
              transactionId: any(named: 'transactionId'),
            )).thenAnswer((_) async => const Right(0));

        // ...but the authoritative wallet endpoint has the correct balance.
        when(() => getWalletBalanceUseCase(userId)).thenAnswer(
          (_) async => const Right(WalletEntity(balance: 500, status: 'active')),
        );

        await cubit.verifyRecharge(
          razorpayOrderId: 'order-1',
          razorpayPaymentId: 'pay-1',
          razorpaySignature: 'sig-1',
          transactionId: 'txn-1',
        );

        expect(cubit.state.status, WalletStatus.loaded);
        expect(cubit.state.balance, 500);
      },
    );

    test(
      'falls back to the verify-payment balance if the post-payment refresh fails',
      () async {
        when(() => verifyPaymentUseCase(
              razorpayOrderId: any(named: 'razorpayOrderId'),
              razorpayPaymentId: any(named: 'razorpayPaymentId'),
              razorpaySignature: any(named: 'razorpaySignature'),
              transactionId: any(named: 'transactionId'),
            )).thenAnswer((_) async => const Right(250));

        when(() => getWalletBalanceUseCase(userId)).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'network error')),
        );

        await cubit.verifyRecharge(
          razorpayOrderId: 'order-1',
          razorpayPaymentId: 'pay-1',
          razorpaySignature: 'sig-1',
          transactionId: 'txn-1',
        );

        expect(cubit.state.status, WalletStatus.loaded);
        expect(cubit.state.balance, 250);
      },
    );

    test('emits paymentFailure when verification itself fails', () async {
      when(() => verifyPaymentUseCase(
            razorpayOrderId: any(named: 'razorpayOrderId'),
            razorpayPaymentId: any(named: 'razorpayPaymentId'),
            razorpaySignature: any(named: 'razorpaySignature'),
            transactionId: any(named: 'transactionId'),
          )).thenAnswer((_) async => const Left(PaymentFailure(message: 'Signature mismatch')));

      await cubit.verifyRecharge(
        razorpayOrderId: 'order-1',
        razorpayPaymentId: 'pay-1',
        razorpaySignature: 'sig-1',
        transactionId: 'txn-1',
      );

      expect(cubit.state.status, WalletStatus.paymentFailure);
      expect(cubit.state.errorMessage, 'Signature mismatch');
      verifyNever(() => getWalletBalanceUseCase(any()));
    });
  });
}
