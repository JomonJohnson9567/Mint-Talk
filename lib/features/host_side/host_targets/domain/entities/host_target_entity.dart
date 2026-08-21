import 'package:equatable/equatable.dart';

class HostTargetEntity extends Equatable {
  final String id;
  final String hostId;
  final String period;
  final String callTypeFilter;
  final DateTime startDate;
  final DateTime endDate;
  final String targetType;
  final num targetValue;
  final num currentValue;
  final String status;

  const HostTargetEntity({
    required this.id,
    required this.hostId,
    required this.period,
    this.callTypeFilter = 'all',
    required this.startDate,
    required this.endDate,
    required this.targetType,
    required this.targetValue,
    required this.currentValue,
    required this.status,
  });

  bool get isAchieved => status.toLowerCase() == 'achieved';

  double get progress =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0, 1).toDouble();

  @override
  List<Object?> get props => [
        id,
        hostId,
        period,
        callTypeFilter,
        startDate,
        endDate,
        targetType,
        targetValue,
        currentValue,
        status,
      ];
}
