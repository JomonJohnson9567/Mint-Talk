import 'package:mint_talk/features/shared/system_config/domain/entities/system_config_entity.dart';

class SystemConfigModel {
  final String billingUnit;
  final int? defaultAudioRate;
  final int? defaultVideoRate;
  final double? hostAudioEarningRateInr;
  final double? hostVideoEarningRateInr;
  final String hostBillingUnit;

  const SystemConfigModel({
    required this.billingUnit,
    required this.hostBillingUnit,
    this.defaultAudioRate,
    this.defaultVideoRate,
    this.hostAudioEarningRateInr,
    this.hostVideoEarningRateInr,
  });

  factory SystemConfigModel.fromJson(Map<String, dynamic> json) {
    return SystemConfigModel(
      billingUnit: _unit(json['billingUnit']),
      // Older configs had no hostBillingUnit and the host rates were ₹/min.
      hostBillingUnit: _unit(json['hostBillingUnit']),
      defaultAudioRate: (json['defaultAudioRate'] as num?)?.toInt(),
      defaultVideoRate: (json['defaultVideoRate'] as num?)?.toInt(),
      hostAudioEarningRateInr: (json['hostDefaultAudioEarningRateINR'] as num?)
          ?.toDouble(),
      hostVideoEarningRateInr: (json['hostDefaultVideoEarningRateINR'] as num?)
          ?.toDouble(),
    );
  }

  /// Normalises the backend unit string ('second' / 'minute', any case);
  /// anything else falls back to 'minute'.
  static String _unit(Object? raw) {
    final value = raw is String ? raw.trim().toLowerCase() : '';
    return value == 'second' ? 'second' : 'minute';
  }

  SystemConfigEntity toEntity() => SystemConfigEntity(
    billingUnit: billingUnit,
    hostBillingUnit: hostBillingUnit,
    defaultAudioRate: defaultAudioRate,
    defaultVideoRate: defaultVideoRate,
    hostAudioEarningRateInr: hostAudioEarningRateInr,
    hostVideoEarningRateInr: hostVideoEarningRateInr,
  );
}
