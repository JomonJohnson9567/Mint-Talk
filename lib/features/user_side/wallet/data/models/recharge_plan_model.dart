import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';

/// DTO for a recharge plan returned by the plans API. Parsing only — display
/// formatting lives on [RechargePlanEntity] via [toEntity].
class RechargePlanModel {
  final String id;
  final String? name;
  final int? points;
  final int? bonusPoints;
  final num? rawPrice;
  final String? currency;

  const RechargePlanModel({
    required this.id,
    this.name,
    this.points,
    this.bonusPoints,
    this.rawPrice,
    this.currency,
  });

  factory RechargePlanModel.fromJson(Map<String, dynamic> json) {
    return RechargePlanModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      points: json['points'],
      bonusPoints: json['bonusPoints'],
      rawPrice: json['price'],
      currency: json['currency'],
    );
  }

  RechargePlanEntity toEntity() => RechargePlanEntity(
        id: id,
        name: name,
        points: points,
        bonusPoints: bonusPoints,
        rawPrice: rawPrice,
        currency: currency,
      );
}
