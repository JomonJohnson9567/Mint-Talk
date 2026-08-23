import 'package:equatable/equatable.dart';

class SystemConfigEntity extends Equatable {
  final String billingUnit;

  const SystemConfigEntity({required this.billingUnit});

  bool get isPerSecondBilling => billingUnit == 'second';

  @override
  List<Object?> get props => [billingUnit];
}
