import 'package:equatable/equatable.dart';

enum HostProfileEditStatus { initial, loading, loaded, saving, success, failure }

class HostProfileEditState extends Equatable {
  final String name;
  final String phone;
  final String idNumber;
  final String dob;
  final List<String> selectedCategories;
  final String avatarAsset;
  final HostProfileEditStatus status;
  final String? errorMessage;
  final bool showErrors;

  const HostProfileEditState({
    this.name = '',
    this.phone = '',
    this.idNumber = '',
    this.dob = '',
    this.selectedCategories = const [],
    this.avatarAsset = '',
    this.status = HostProfileEditStatus.initial,
    this.errorMessage,
    this.showErrors = false,
  });

  HostProfileEditState copyWith({
    String? name,
    String? phone,
    String? idNumber,
    String? dob,
    List<String>? selectedCategories,
    String? avatarAsset,
    HostProfileEditStatus? status,
    String? errorMessage,
    bool? showErrors,
  }) {
    return HostProfileEditState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      idNumber: idNumber ?? this.idNumber,
      dob: dob ?? this.dob,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
        name,
        phone,
        idNumber,
        dob,
        selectedCategories,
        avatarAsset,
        status,
        errorMessage,
        showErrors,
      ];
}
