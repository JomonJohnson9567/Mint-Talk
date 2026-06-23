import 'package:country_picker/country_picker.dart';
import 'package:equatable/equatable.dart';

enum ApplyForHostStatus { initial, submitting, success, failure }

class ApplyForHostState extends Equatable {
  final String name;
  final String bio;
  final String phone;
  final String dob;
  final Country selectedCountry;
  final String aadhaarNumber;
  final String aadhaarFrontPath;
  final String aadhaarBackPath;
  final String selfiePath;
  
  // Remote URLs returned after uploading
  final String aadhaarFrontUrl;
  final String aadhaarBackUrl;
  final String selfieUrl;

  // Individual upload state flags
  final bool isUploadingFront;
  final bool isUploadingBack;
  final bool isUploadingSelfie;

  final ApplyForHostStatus status;
  final String? errorMessage;
  final Map<String, String> fieldErrors;

  const ApplyForHostState({
    this.name = '',
    this.bio = '',
    this.phone = '',
    this.dob = '',
    required this.selectedCountry,
    this.aadhaarNumber = '',
    this.aadhaarFrontPath = '',
    this.aadhaarBackPath = '',
    this.selfiePath = '',
    this.aadhaarFrontUrl = '',
    this.aadhaarBackUrl = '',
    this.selfieUrl = '',
    this.isUploadingFront = false,
    this.isUploadingBack = false,
    this.isUploadingSelfie = false,
    this.status = ApplyForHostStatus.initial,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  bool get isFormValid =>
      name.isNotEmpty &&
      bio.isNotEmpty &&
      phone.isNotEmpty &&
      dob.isNotEmpty &&
      aadhaarNumber.isNotEmpty &&
      aadhaarFrontPath.isNotEmpty &&
      aadhaarBackPath.isNotEmpty &&
      selfiePath.isNotEmpty &&
      aadhaarFrontUrl.isNotEmpty &&
      aadhaarBackUrl.isNotEmpty &&
      selfieUrl.isNotEmpty &&
      !isUploadingFront &&
      !isUploadingBack &&
      !isUploadingSelfie &&
      fieldErrors.values.every((error) => error.isEmpty);

  ApplyForHostState copyWith({
    String? name,
    String? bio,
    String? phone,
    String? dob,
    Country? selectedCountry,
    String? aadhaarNumber,
    String? aadhaarFrontPath,
    String? aadhaarBackPath,
    String? selfiePath,
    String? aadhaarFrontUrl,
    String? aadhaarBackUrl,
    String? selfieUrl,
    bool? isUploadingFront,
    bool? isUploadingBack,
    bool? isUploadingSelfie,
    ApplyForHostStatus? status,
    String? errorMessage,
    Map<String, String>? fieldErrors,
  }) {
    return ApplyForHostState(
      name: name ?? this.name,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarFrontPath: aadhaarFrontPath ?? this.aadhaarFrontPath,
      aadhaarBackPath: aadhaarBackPath ?? this.aadhaarBackPath,
      selfiePath: selfiePath ?? this.selfiePath,
      aadhaarFrontUrl: aadhaarFrontUrl ?? this.aadhaarFrontUrl,
      aadhaarBackUrl: aadhaarBackUrl ?? this.aadhaarBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      isUploadingFront: isUploadingFront ?? this.isUploadingFront,
      isUploadingBack: isUploadingBack ?? this.isUploadingBack,
      isUploadingSelfie: isUploadingSelfie ?? this.isUploadingSelfie,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  List<Object?> get props => [
        name,
        bio,
        phone,
        dob,
        selectedCountry,
        aadhaarNumber,
        aadhaarFrontPath,
        aadhaarBackPath,
        selfiePath,
        aadhaarFrontUrl,
        aadhaarBackUrl,
        selfieUrl,
        isUploadingFront,
        isUploadingBack,
        isUploadingSelfie,
        status,
        errorMessage,
        fieldErrors,
      ];
}
