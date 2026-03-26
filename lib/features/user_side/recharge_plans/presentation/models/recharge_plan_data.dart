import 'package:mint_talk/core/constants/app_texts.dart';

import 'recharge_plan_item.dart';
import 'recharge_plan_section.dart';

class RechargePlanData {
  RechargePlanData._();

  static const List<RechargePlanSection> sections = [
    RechargePlanSection(
      title: AppTexts.standardPackages,
      plans: [
        RechargePlanItem(
          coins: AppTexts.coins10000,
          price: AppTexts.price120,
        ),
        RechargePlanItem(
          coins: AppTexts.coins17500,
          price: AppTexts.price210,
        ),
        RechargePlanItem(
          coins: AppTexts.coins35000,
          price: AppTexts.price420,
          badgeText: AppTexts.mostPopular,
        ),
        RechargePlanItem(
          coins: AppTexts.coins70000,
          price: AppTexts.price840,
        ),
        RechargePlanItem(
          coins: AppTexts.coins125000,
          price: AppTexts.price1498,
          badgeText: AppTexts.bestValue,
        ),
        RechargePlanItem(
          coins: AppTexts.coins250000,
          price: AppTexts.price2996,
        ),
      ],
    ),
    RechargePlanSection(
      title: AppTexts.dhamakkaOffer,
      plans: [
        RechargePlanItem(
          coins: AppTexts.coins375000,
          price: AppTexts.price4494,
          badgeText: AppTexts.saverPack,
        ),
        RechargePlanItem(
          coins: AppTexts.coins500000,
          price: AppTexts.price4949,
          badgeText: AppTexts.saverPack,
        ),
        RechargePlanItem(
          coins: AppTexts.coins1000000,
          price: AppTexts.price11898,
          badgeText: AppTexts.saverPack,
        ),
      ],
    ),
    RechargePlanSection(
      title: AppTexts.specialOffer,
      plans: [
        RechargePlanItem(
          coins: AppTexts.coins10000,
          price: AppTexts.price999,
        ),
        RechargePlanItem(
          coins: AppTexts.coins500000,
          price: AppTexts.price4949,
        ),
        RechargePlanItem(
          coins: AppTexts.coins1000000,
          price: AppTexts.price11898,
        ),
      ],
    ),
  ];
}
