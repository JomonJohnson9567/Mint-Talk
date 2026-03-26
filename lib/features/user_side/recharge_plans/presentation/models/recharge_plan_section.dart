import 'recharge_plan_item.dart';

class RechargePlanSection {
  final String title;
  final List<RechargePlanItem> plans;

  const RechargePlanSection({
    required this.title,
    required this.plans,
  });
}
