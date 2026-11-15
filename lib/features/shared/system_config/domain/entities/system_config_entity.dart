import 'package:equatable/equatable.dart';

class SystemConfigEntity extends Equatable {
  final String billingUnit;

  /// Default call rates, already expressed in [billingUnit] (no conversion).
  final int? defaultAudioRate;
  final int? defaultVideoRate;

  /// Host default earning rates in ₹ per [hostBillingUnit]
  /// (`hostDefaultAudioEarningRateINR` / `hostDefaultVideoEarningRateINR`).
  final double? hostAudioEarningRateInr;
  final double? hostVideoEarningRateInr;

  /// 'second' or 'minute' — the unit the host earning rates are quoted in.
  final String hostBillingUnit;

  const SystemConfigEntity({
    required this.billingUnit,
    this.hostBillingUnit = 'minute',
    this.defaultAudioRate,
    this.defaultVideoRate,
    this.hostAudioEarningRateInr,
    this.hostVideoEarningRateInr,
  });

  bool get isPerSecondBilling => billingUnit == 'second';

  @override
  List<Object?> get props => [
    billingUnit,
    hostBillingUnit,
    defaultAudioRate,
    defaultVideoRate,
    hostAudioEarningRateInr,
    hostVideoEarningRateInr,
  ];
}
