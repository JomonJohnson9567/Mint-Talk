import 'package:equatable/equatable.dart';
import '../../domain/entities/host_application_status_entity.dart';

enum HostApplicationStatusView { initial, loading, loaded, failure }

class HostApplicationStatusState extends Equatable {
  final HostApplicationStatusView view;
  final HostApplicationStatusEntity? application;
  final String? errorMessage;

  const HostApplicationStatusState({
    this.view = HostApplicationStatusView.initial,
    this.application,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [view, application, errorMessage];
}
