import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/apply_for_host/data/models/host_application_model.dart';
import 'package:mint_talk/features/user_side/apply_for_host/domain/entities/host_application_entity.dart';

void main() {
  const entity = HostApplicationEntity(
    name: 'Asha',
    dob: '5/3/1999',
    bio: 'Friendly listener who loves music.',
    verificationPhotoId: 'vp_123',
  );

  test('sends verificationPhotoId and never selfieUrl', () {
    final json = HostApplicationModel.fromEntity(entity).toJson();

    expect(json['verificationPhotoId'], 'vp_123');
    expect(json.containsKey('selfieUrl'), isFalse);
    expect(json.containsKey('referralCode'), isFalse);
  });

  test('converts d/M/yyyy dob to ISO yyyy-MM-dd', () {
    final json = HostApplicationModel.fromEntity(entity).toJson();
    expect(json['dob'], '1999-03-05');
  });

  test('includes trimmed referral code when present', () {
    const withCode = HostApplicationEntity(
      name: 'Asha',
      dob: '5/3/1999',
      bio: 'Friendly listener who loves music.',
      verificationPhotoId: 'vp_123',
      referralCode: ' ABC123 ',
    );
    expect(
      HostApplicationModel.fromEntity(withCode).toJson()['referralCode'],
      'ABC123',
    );
  });
}
