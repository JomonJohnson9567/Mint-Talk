import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';

enum PlanDetailStatus { initial, loading, loaded, failure }

class PlanDetailState extends Equatable {
  final PlanDetailStatus status;
  final RechargePlanItem? plan;
  final String? errorMessage;

  const PlanDetailState({
    this.status = PlanDetailStatus.initial,
    this.plan,
    this.errorMessage,
  });

  bool get isLoading => status == PlanDetailStatus.loading;

  PlanDetailState copyWith({
    PlanDetailStatus? status,
    RechargePlanItem? plan,
    String? Function()? errorMessage,
  }) {
    return PlanDetailState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, plan, errorMessage];
}
