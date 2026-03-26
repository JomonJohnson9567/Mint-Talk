import 'package:equatable/equatable.dart';

enum HostProfileSetupStatus { initial, submitting, success, failure }

class HostProfileSetupState extends Equatable {
  final String name;
  final String dob;
  final List<String> selectedCategories;
  final HostProfileSetupStatus status;
  final bool showErrors;

  const HostProfileSetupState({
    this.name = '',
    this.dob = '',
    this.selectedCategories = const [],
    this.status = HostProfileSetupStatus.initial,
    this.showErrors = false,
  });

  HostProfileSetupState copyWith({
    String? name,
    String? dob,
    List<String>? selectedCategories,
    HostProfileSetupStatus? status,
    bool? showErrors,
  }) {
    return HostProfileSetupState(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      status: status ?? this.status,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [name, dob, selectedCategories, status, showErrors];
}
