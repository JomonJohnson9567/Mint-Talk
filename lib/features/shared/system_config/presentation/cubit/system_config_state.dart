import 'package:equatable/equatable.dart';

enum SystemConfigStatus { initial, loading, loaded, failure }

class SystemConfigState extends Equatable {
  final SystemConfigStatus status;
  final String billingUnit;

  /// Defaults to per-minute billing so every rate label already in the app
  /// keeps showing its current "/min" text until the real config loads (or
  /// if the fetch fails) — same fail-open default the backend uses.
  const SystemConfigState({
    this.status = SystemConfigStatus.initial,
    this.billingUnit = 'minute',
  });

  bool get isPerSecondBilling => billingUnit == 'second';

  SystemConfigState copyWith({
    SystemConfigStatus? status,
    String? billingUnit,
  }) {
    return SystemConfigState(
      status: status ?? this.status,
      billingUnit: billingUnit ?? this.billingUnit,
    );
  }

  @override
  List<Object?> get props => [status, billingUnit];
}
