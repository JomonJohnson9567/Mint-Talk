import 'package:equatable/equatable.dart';

enum ApplyForHostStatus { initial, submitting, success, failure }

class ApplyForHostState extends Equatable {
  final String name;
  final String dob;
  final String selfiePath;
  final String selfieUrl;

  final bool isUploadingSelfie;

  final ApplyForHostStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const ApplyForHostState({
    this.name = '',
    this.dob = '',
    this.selfiePath = '',
    this.selfieUrl = '',
    this.isUploadingSelfie = false,
    this.status = ApplyForHostStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  bool get isFormValid =>
      name.trim().length >= 3 &&
      name.trim().length <= 50 &&
      dob.isNotEmpty &&
      selfiePath.isNotEmpty &&
      selfieUrl.isNotEmpty &&
      !isUploadingSelfie &&
      fieldErrors.values.every((error) => error.isEmpty);

  ApplyForHostState copyWith({
    String? name,
    String? dob,
    String? selfiePath,
    String? selfieUrl,
    bool? isUploadingSelfie,
    ApplyForHostStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return ApplyForHostState(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      selfiePath: selfiePath ?? this.selfiePath,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      isUploadingSelfie: isUploadingSelfie ?? this.isUploadingSelfie,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
    name,
    dob,
    selfiePath,
    selfieUrl,
    isUploadingSelfie,
    status,
    errorMessage,
    fieldErrors,
  ];
}
