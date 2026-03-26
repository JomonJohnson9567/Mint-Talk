class RechargePlanItem {
  final String coins;
  final String price;
  final String? badgeText;

  const RechargePlanItem({
    required this.coins,
    required this.price,
    this.badgeText,
  });
}
