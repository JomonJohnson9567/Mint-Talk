import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

class RechargePlanSection {
  final String title;
  final List<RechargePlanEntity> plans;

  const RechargePlanSection({
    required this.title,
    required this.plans,
  });
}
