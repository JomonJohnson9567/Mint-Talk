// The plans list hands its plan to the detail screen so it renders without
// a fetch — fallback-catalogue ids are unknown to the backend, so fetching
// them by id always fails.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/cubit/plan_detail_cubit.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/cubit/plan_detail_state.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_plan_by_id_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetPlanByIdUseCase extends Mock implements GetPlanByIdUseCase {}

void main() {
  late _MockGetPlanByIdUseCase getPlanByIdUseCase;
  late PlanDetailCubit cubit;

  const plan = RechargePlanEntity(id: 'p1', points: 85000, rawPrice: 1000);

  setUp(() {
    getPlanByIdUseCase = _MockGetPlanByIdUseCase();
    cubit = PlanDetailCubit(getPlanByIdUseCase);
  });

  tearDown(() => cubit.close());

  group('loadPlan', () {
    test('shows the initial plan without fetching it', () async {
      await cubit.loadPlan('p1', initial: plan);

      expect(cubit.state.status, PlanDetailStatus.loaded);
      expect(cubit.state.plan, plan);
      verifyNever(() => getPlanByIdUseCase(any()));
    });

    test('fetches by id when no initial plan is given', () async {
      when(() => getPlanByIdUseCase('p1'))
          .thenAnswer((_) async => const Right(plan));

      await cubit.loadPlan('p1');

      expect(cubit.state.status, PlanDetailStatus.loaded);
      expect(cubit.state.plan, plan);
    });

    test('emits failure with the message when the fetch fails', () async {
      when(() => getPlanByIdUseCase('p1')).thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Plan not found')),
      );

      await cubit.loadPlan('p1');

      expect(cubit.state.status, PlanDetailStatus.failure);
      expect(cubit.state.errorMessage, 'Plan not found');
      expect(cubit.state.plan, isNull);
    });
  });
}
