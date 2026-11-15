import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/wallet/domain/usecases/get_plan_by_id_usecase.dart';
import 'plan_detail_state.dart';

@injectable
class PlanDetailCubit extends Cubit<PlanDetailState> {
  final GetPlanByIdUseCase _getPlanByIdUseCase;

  PlanDetailCubit(this._getPlanByIdUseCase) : super(const PlanDetailState());

  /// Shows [initial] straight away when the caller already has the plan
  /// (e.g. the recharge plans list) — no fetch, so no skeleton flash, and
  /// fallback-catalogue ids the backend doesn't know still render.
  Future<void> loadPlan(String planId, {RechargePlanEntity? initial}) async {
    if (initial != null) {
      emit(state.copyWith(status: PlanDetailStatus.loaded, plan: initial));
      return;
    }
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

  RechargePlanEntity? get currentPlan => state.plan;
}
