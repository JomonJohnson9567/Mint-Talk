import 'package:equatable/equatable.dart';

enum HostProfileEditStatus {
  initial,
  loading,
  loaded,
  saving,
  success,
  failure,
}

class HostProfileEditState extends Equatable {
  final String name;
  final String phone;
  final String idNumber;
  final String dob;
  final String gender;
  final List<String> selectedCategories;
  final String avatarAsset;

  /// Values as loaded, so [hasChanges] can tell whether there's anything to
  /// save.
  final String initialName;
  final String initialAvatarAsset;
  final List<String> initialCategories;
  final HostProfileEditStatus status;
  final String? errorMessage;
  final bool showErrors;

  /// Inline validation error for the name field, if any.
  final String? nameError;

  const HostProfileEditState({
    this.name = '',
    this.phone = '',
    this.idNumber = '',
    this.dob = '',
    this.gender = '',
    this.selectedCategories = const [],
    this.avatarAsset = '',
    this.initialName = '',
    this.initialAvatarAsset = '',
    this.initialCategories = const [],
    this.status = HostProfileEditStatus.initial,
    this.errorMessage,
    this.showErrors = false,
    this.nameError,
  });

  bool get isSaving => status == HostProfileEditStatus.saving;

  bool get hasChanges =>
      name.trim() != initialName.trim() ||
      avatarAsset != initialAvatarAsset ||
      selectedCategories.length != initialCategories.length ||
      !selectedCategories.every(initialCategories.contains);

  HostProfileEditState copyWith({
    String? name,
    String? phone,
    String? idNumber,
    String? dob,
    String? gender,
    List<String>? selectedCategories,
    String? avatarAsset,
    String? initialName,
    String? initialAvatarAsset,
    List<String>? initialCategories,
    HostProfileEditStatus? status,
    String? errorMessage,
    bool? showErrors,
    String? nameError,
    bool clearNameError = false,
  }) {
    return HostProfileEditState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      idNumber: idNumber ?? this.idNumber,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      initialName: initialName ?? this.initialName,
      initialAvatarAsset: initialAvatarAsset ?? this.initialAvatarAsset,
      initialCategories: initialCategories ?? this.initialCategories,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      showErrors: showErrors ?? this.showErrors,
      nameError: clearNameError ? null : (nameError ?? this.nameError),
    );
  }

  @override
  List<Object?> get props => [
    name,
    phone,
    idNumber,
    dob,
    gender,
    selectedCategories,
    avatarAsset,
    initialName,
    initialAvatarAsset,
    initialCategories,
    status,
    errorMessage,
    showErrors,
    nameError,
  ];
}
