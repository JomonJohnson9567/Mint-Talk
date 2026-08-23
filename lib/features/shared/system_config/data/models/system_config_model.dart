import 'package:mint_talk/features/shared/system_config/domain/entities/system_config_entity.dart';

class SystemConfigModel {
  final String billingUnit;

  const SystemConfigModel({required this.billingUnit});

  factory SystemConfigModel.fromJson(Map<String, dynamic> json) {
    return SystemConfigModel(
      billingUnit: (json['billingUnit'] as String?) ?? 'minute',
    );
  }

  SystemConfigEntity toEntity() => SystemConfigEntity(billingUnit: billingUnit);
}
