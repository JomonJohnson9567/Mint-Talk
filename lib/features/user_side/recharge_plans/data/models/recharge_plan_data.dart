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
          id: 'plan_10k',
          coins: AppTexts.coins10000,
          price: AppTexts.price120,
        ),
        RechargePlanItem(
          id: 'plan_17_5k',
          coins: AppTexts.coins17500,
          price: AppTexts.price210,
        ),
        RechargePlanItem(
          id: 'plan_35k',
          coins: AppTexts.coins35000,
          price: AppTexts.price420,
          badgeText: AppTexts.mostPopular,
        ),
        RechargePlanItem(
          id: 'plan_70k',
          coins: AppTexts.coins70000,
          price: AppTexts.price840,
        ),
        RechargePlanItem(
          id: 'plan_125k',
          coins: AppTexts.coins125000,
          price: AppTexts.price1498,
          badgeText: AppTexts.bestValue,
        ),
        RechargePlanItem(
          id: 'plan_250k',
          coins: AppTexts.coins250000,
          price: AppTexts.price2996,
        ),
      ],
    ),
    RechargePlanSection(
      title: AppTexts.dhamakkaOffer,
      plans: [
        RechargePlanItem(
          id: 'offer_375k',
          coins: AppTexts.coins375000,
          price: AppTexts.price4494,
          badgeText: AppTexts.saverPack,
        ),
        RechargePlanItem(
          id: 'offer_500k',
          coins: AppTexts.coins500000,
          price: AppTexts.price4949,
          badgeText: AppTexts.saverPack,
        ),
        RechargePlanItem(
          id: 'offer_1m',
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
          id: 'special_10k',
          coins: AppTexts.coins10000,
          price: AppTexts.price999,
        ),
        RechargePlanItem(
          id: 'special_500k',
          coins: AppTexts.coins500000,
          price: AppTexts.price4949,
        ),
        RechargePlanItem(
          id: 'special_1m',
          coins: AppTexts.coins1000000,
          price: AppTexts.price11898,
        ),
      ],
    ),
  ];
}
