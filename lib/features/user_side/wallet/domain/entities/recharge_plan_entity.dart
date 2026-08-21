import 'package:equatable/equatable.dart';

/// A recharge plan, whether sourced from the backend catalogue or from the
/// static fallback list in `recharge_plans/data/models/recharge_plan_data.dart`.
///
/// Carries the same display-formatting getters the UI has always used
/// ([coins], [price], [displayBadge], [numericPrice]) so moving plans from a
/// data-layer DTO to this domain entity doesn't change anything rendered.
class RechargePlanEntity extends Equatable {
  final String id;
  final String? name;
  final int? points;
  final int? bonusPoints;
  final num? rawPrice;
  final String? currency;
  final String? badgeText;
  final String? _staticPrice;
  final String? _staticCoins;

  const RechargePlanEntity({
    required this.id,
    this.name,
    this.points,
    this.bonusPoints,
    this.rawPrice,
    this.currency,
    this.badgeText,
    String? price,
    String? coins,
  })  : _staticPrice = price,
        _staticCoins = coins;

  String get coins => _staticCoins ?? '${points ?? 0} Coins';
  String get price => _staticPrice ?? '${currency ?? '₹'} ${rawPrice ?? 0}';
  String get displayBadge =>
      badgeText ??
      (bonusPoints != null && bonusPoints! > 0
          ? '+$bonusPoints Bonus'
          : (name ?? ''));

  double get numericPrice {
    if (rawPrice != null) return rawPrice!.toDouble();
    if (_staticPrice != null) {
      return double.tryParse(_staticPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        points,
        bonusPoints,
        rawPrice,
        currency,
        badgeText,
        _staticPrice,
        _staticCoins,
      ];
}
