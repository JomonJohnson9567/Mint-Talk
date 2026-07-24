import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_plan_by_id_usecase.dart';
import 'plan_detail_state.dart';

@injectable
class PlanDetailCubit extends Cubit<PlanDetailState> {
  final GetPlanByIdUseCase _getPlanByIdUseCase;

  PlanDetailCubit(this._getPlanByIdUseCase) : super(const PlanDetailState());

  Future<void> loadPlan(String planId) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: PlanDetailStatus.loading,
        errorMessage: () => null,
      ),
    );

    final result = await _getPlanByIdUseCase(planId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: PlanDetailStatus.failure,
          errorMessage: () => failure.message,
        ),
      ),
      (plan) => emit(
        state.copyWith(
          status: PlanDetailStatus.loaded,
          plan: plan,
          errorMessage: () => null,
        ),
      ),
    );
  }

  RechargePlanItem? get currentPlan => state.plan;
}
