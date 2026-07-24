import 'package:equatable/equatable.dart';

/// Domain entity representing a Host's profile.
/// Strictly decoupled from data, widgets, or any Flutter framework details.
class HostProfileEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String idNumber;
  final String dob;
  final List<String> selectedCategories;
  final String avatarAsset;

  const HostProfileEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.idNumber,
    required this.dob,
    required this.selectedCategories,
    required this.avatarAsset,
  });

  HostProfileEntity copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? idNumber,
    String? dob,
    List<String>? selectedCategories,
    String? avatarAsset,
  }) {
    return HostProfileEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      idNumber: idNumber ?? this.idNumber,
      dob: dob ?? this.dob,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      avatarAsset: avatarAsset ?? this.avatarAsset,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        idNumber,
        dob,
        selectedCategories,
        avatarAsset,
      ];
}
