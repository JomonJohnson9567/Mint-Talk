class RechargePlanItem {
  final String id;
  final String? name;
  final int? points; // Use int for points from API
  final int? bonusPoints;
  final num? rawPrice; // Use num for price from API
  final String? currency;
  final String? badgeText; // Keep for dummy plans
  final String? _staticPrice; // Keep for dummy plans
  final String? _staticCoins; // Keep for dummy plans

  const RechargePlanItem({
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

  // UI Getters for compatibility
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
      // Strips non-numeric characters (like currency symbols) and parses
      return double.tryParse(_staticPrice!.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;
    }
    return 0.0;
  }

  factory RechargePlanItem.fromJson(Map<String, dynamic> json) {
    return RechargePlanItem(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'],
      points: json['points'],
      bonusPoints: json['bonusPoints'],
      rawPrice: json['price'],
      currency: json['currency'],
    );
  }
}
