// Regression test for the recharge/balance bug: verifyRecharge() must trust
// a fresh getWalletBalance() fetch over whatever balance the verify-payment
// response happened to parse out, since that response's shape/staleness is
// not fully controlled by this app.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/razorpay_service.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_data.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/order_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/payment_method.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/wallet_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/create_order_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_plans_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_wallet_balance_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/initialize_wallet_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/verify_payment_usecase.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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

  // The static catalogue is a fallback only: its ids aren't known to the
  // backend, so it must never be mixed into a real API response.
  group('fetchPlans', () {
    final fallbackPlans =
        RechargePlanData.sections.expand((section) => section.plans).toList();

    test('emits only the API plans, sorted cheapest first', () async {
      when(() => getPlansUseCase(NoParams())).thenAnswer(
        (_) async => const Right([
          RechargePlanEntity(id: 'p2', points: 85000, rawPrice: 1000),
          RechargePlanEntity(id: 'p3', points: 180000, rawPrice: 2000),
          RechargePlanEntity(id: 'p1', points: 40000, rawPrice: 500),
        ]),
      );

      await cubit.fetchPlans();

      expect(cubit.state.status, WalletStatus.plansLoaded);
      expect(cubit.state.plans.map((p) => p.id), ['p1', 'p2', 'p3']);
    });

    test('falls back to the static catalogue when the API fails', () async {
      when(() => getPlansUseCase(NoParams())).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'network error')),
      );

      await cubit.fetchPlans();

      expect(cubit.state.status, WalletStatus.plansLoaded);
      expect(
        cubit.state.plans.map((p) => p.id).toSet(),
        fallbackPlans.map((p) => p.id).toSet(),
      );
    });

    test('sorts the fallback catalogue by price', () async {
      when(() => getPlansUseCase(NoParams()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'x')));

      await cubit.fetchPlans();

      final prices = cubit.state.plans.map((p) => p.numericPrice).toList();
      expect(prices, [...prices]..sort());
    });

    test('falls back to the static catalogue when the API has no plans', () async {
      when(() => getPlansUseCase(NoParams()))
          .thenAnswer((_) async => const Right(<RechargePlanEntity>[]));

      await cubit.fetchPlans();

      expect(cubit.state.plans, hasLength(fallbackPlans.length));
      final prices = cubit.state.plans.map((p) => p.numericPrice).toList();
      expect(prices, [...prices]..sort());
    });
  });

  // The user picks a method in the payment sheet; checkout must then show
  // only that method, via Razorpay's config.display.
  group('startRecharge', () {
    const order = OrderEntity(
      orderId: 'order_1',
      amount: 100000,
      currency: 'INR',
      transactionId: 'txn-1',
      key: 'rzp_test_key',
      pointsToCredit: 85000,
    );

    setUp(() {
      when(() => createOrderUseCase('plan-1'))
          .thenAnswer((_) async => const Right(order));
    });

    Future<Map<String, dynamic>> openedOptions(PaymentMethod method) async {
      await cubit.startRecharge('plan-1', method: method);
      return verify(() => razorpayService.open(captureAny())).captured.single
          as Map<String, dynamic>;
    }

    for (final (method, razorpayMethod) in const [
      (PaymentMethod.upi, 'upi'),
      (PaymentMethod.card, 'card'),
      (PaymentMethod.netbanking, 'netbanking'),
    ]) {
      test('opens checkout showing only $razorpayMethod', () async {
        when(() => authRepository.getPhone()).thenAnswer((_) async => null);

        final options = await openedOptions(method);
        final display = options['config']['display'] as Map<String, dynamic>;
        final blocks = display['blocks'] as Map<String, dynamic>;

        expect(blocks.keys, ['selected']);
        expect(blocks['selected']['instruments'], [
          {'method': razorpayMethod},
        ]);
        expect(display['sequence'], ['block.selected']);
        expect(display['preferences'], {'show_default_blocks': false});
        expect(options['order_id'], 'order_1');
      });
    }

    test('prefills the logged-in phone number', () async {
      when(() => authRepository.getPhone())
          .thenAnswer((_) async => ' +919876543210 ');

      final options = await openedOptions(PaymentMethod.upi);

      expect(options['prefill']['contact'], '+919876543210');
    });

    test('leaves contact out when no phone is stored', () async {
      when(() => authRepository.getPhone()).thenAnswer((_) async => null);

      final options = await openedOptions(PaymentMethod.card);

      expect((options['prefill'] as Map).containsKey('contact'), isFalse);
    });

    group('when checkout reports an error', () {
      const noMethods =
          '{"error":{"code":"BAD_REQUEST_ERROR","description":"no_payment_methods",'
          '"source":"razorpay","step":"checkout_load","reason":"no_payment_methods"}}';

      // Razorpay delivers errors through the onError callback given to init().
      void Function(PaymentFailureResponse) onError() =>
          verify(
                () => razorpayService.init(
                  onSuccess: any(named: 'onSuccess'),
                  onError: captureAny(named: 'onError'),
                ),
              ).captured.last
              as void Function(PaymentFailureResponse);

      setUp(() {
        when(() => authRepository.getPhone()).thenAnswer((_) async => null);
      });

      test(
        'reopens the same order once without the method filter when the '
        'chosen method is unavailable',
        () async {
          await cubit.startRecharge('plan-1', method: PaymentMethod.upi);
          onError()(PaymentFailureResponse(0, noMethods, null));

          final opened = verify(
            () => razorpayService.open(captureAny()),
          ).captured.cast<Map<String, dynamic>>();
          expect(opened, hasLength(2));
          expect(opened.last.containsKey('config'), isFalse);
          expect(opened.last['order_id'], 'order_1');
          expect(opened.last['prefill']['method'], 'upi');
          expect(cubit.state.status, isNot(WalletStatus.paymentFailure));
        },
      );

      test('fails with a readable message if it happens again', () async {
        await cubit.startRecharge('plan-1', method: PaymentMethod.upi);
        final handler = onError();
        handler(PaymentFailureResponse(0, noMethods, null));
        handler(PaymentFailureResponse(0, noMethods, null));

        expect(cubit.state.status, WalletStatus.paymentFailure);
        expect(cubit.state.errorMessage, isNot(contains('{')));
        expect(cubit.state.errorMessage, contains('payment method'));
      });

      test('shows the description, not raw JSON, for other errors', () async {
        await cubit.startRecharge('plan-1', method: PaymentMethod.card);
        onError()(
          PaymentFailureResponse(
            0,
            '{"error":{"description":"Your card was declined","reason":"card_declined"}}',
            null,
          ),
        );

        expect(cubit.state.status, WalletStatus.paymentFailure);
        expect(cubit.state.errorMessage, 'Your card was declined');
      });

      test('says "Payment cancelled" when the user backs out', () async {
        await cubit.startRecharge('plan-1', method: PaymentMethod.card);
        onError()(
          PaymentFailureResponse(Razorpay.PAYMENT_CANCELLED, 'undefined', null),
        );

        expect(cubit.state.errorMessage, 'Payment cancelled');
      });
    });

    test('does not open checkout when order creation fails', () async {
      when(() => createOrderUseCase('plan-1')).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Order failed')),
      );
      when(() => authRepository.getPhone()).thenAnswer((_) async => null);

      await cubit.startRecharge('plan-1', method: PaymentMethod.upi);

      expect(cubit.state.status, WalletStatus.paymentFailure);
      expect(cubit.state.errorMessage, 'Order failed');
      verifyNever(() => razorpayService.open(any()));
    });
  });
}
