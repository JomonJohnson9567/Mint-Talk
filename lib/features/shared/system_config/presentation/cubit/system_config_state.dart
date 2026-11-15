import 'package:equatable/equatable.dart';

enum SystemConfigStatus { initial, loading, loaded, failure }

class SystemConfigState extends Equatable {
  final SystemConfigStatus status;
  final String billingUnit;

  /// Default call rates, already in [billingUnit]. Null until the config
  /// loads, so rate labels show "--" rather than a made-up number.
  final int? defaultAudioRate;
  final int? defaultVideoRate;

  /// Host default earning rates in ₹ per [hostBillingUnit], shown on the
  /// host-side rate chips/tiles. Null until the config loads.
  final double? hostAudioEarningRateInr;
  final double? hostVideoEarningRateInr;

  /// 'second' or 'minute' — the unit the host earning rates are quoted in
  /// (`hostBillingUnit`), independent of the client [billingUnit].
  final String hostBillingUnit;

  /// Defaults to per-minute billing so every rate label already in the app
  /// keeps showing its current "/min" text until the real config loads (or
  /// if the fetch fails) — same fail-open default the backend uses.
  const SystemConfigState({
    this.status = SystemConfigStatus.initial,
    this.billingUnit = 'minute',
    this.hostBillingUnit = 'minute',
    this.defaultAudioRate,
    this.defaultVideoRate,
    this.hostAudioEarningRateInr,
    this.hostVideoEarningRateInr,
  });

  bool get isPerSecondBilling => billingUnit == 'second';
  bool get isHostPerSecondBilling => hostBillingUnit == 'second';

  SystemConfigState copyWith({
    SystemConfigStatus? status,
    String? billingUnit,
    String? hostBillingUnit,
    int? defaultAudioRate,
    int? defaultVideoRate,
    double? hostAudioEarningRateInr,
    double? hostVideoEarningRateInr,
  }) {
    return SystemConfigState(
      status: status ?? this.status,
      billingUnit: billingUnit ?? this.billingUnit,
      hostBillingUnit: hostBillingUnit ?? this.hostBillingUnit,
      defaultAudioRate: defaultAudioRate ?? this.defaultAudioRate,
      defaultVideoRate: defaultVideoRate ?? this.defaultVideoRate,
      hostAudioEarningRateInr:
          hostAudioEarningRateInr ?? this.hostAudioEarningRateInr,
      hostVideoEarningRateInr:
          hostVideoEarningRateInr ?? this.hostVideoEarningRateInr,
    );
  }

  @override
  List<Object?> get props => [
    status,
    billingUnit,
    hostBillingUnit,
    defaultAudioRate,
    defaultVideoRate,
    hostAudioEarningRateInr,
    hostVideoEarningRateInr,
  ];
}
