import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

enum ProfileSetupStatus { initial, submitting, success, failure }

class ProfileSetupState extends Equatable {
  final String name;
  final String dob;
  final String gender;
  final AutovalidateMode autovalidateMode;
  final String? genderError;
  final ProfileSetupStatus status;

  const ProfileSetupState({
    this.name = '',
    this.dob = '',
    this.gender = '',
    this.autovalidateMode = AutovalidateMode.disabled,
    this.genderError,
    this.status = ProfileSetupStatus.initial,
  });

  ProfileSetupState copyWith({
    String? name,
    String? dob,
    String? gender,
    AutovalidateMode? autovalidateMode,
    String? genderError,
    bool clearGenderError = false,
    ProfileSetupStatus? status,
  }) {
    return ProfileSetupState(
      name: name ?? this.name,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      genderError: clearGenderError ? null : (genderError ?? this.genderError),
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    name,
    dob,
    gender,
    autovalidateMode,
    genderError,
    status,
  ];
}
