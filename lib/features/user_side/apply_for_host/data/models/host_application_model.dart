import '../../domain/entities/host_application_entity.dart';

class HostApplicationModel extends HostApplicationEntity {
  const HostApplicationModel({
    required super.name,
    required super.dob,
    required super.bio,
    required super.verificationPhotoId,
    super.referralCode,
  });

  factory HostApplicationModel.fromEntity(HostApplicationEntity entity) {
    return HostApplicationModel(
      name: entity.name,
      dob: entity.dob,
      bio: entity.bio,
      verificationPhotoId: entity.verificationPhotoId,
      referralCode: entity.referralCode,
    );
  }

  Map<String, dynamic> toJson() {
    final code = referralCode?.trim();
    return {
      'name': name,
      'dob': _isoDob(dob),
      'bio': bio,
      // The backend no longer accepts `selfieUrl`.
      'verificationPhotoId': verificationPhotoId,
      // Optional — only sent when the applicant entered one.
      if (code != null && code.isNotEmpty) 'referralCode': code,
    };
  }

  /// Converts the UI's `d/M/yyyy` dob string to `yyyy-MM-dd` for the API.
  static String _isoDob(String dob) {
    final parts = dob.split('/');
    if (parts.length != 3) return dob;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return dob;

    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }
}
