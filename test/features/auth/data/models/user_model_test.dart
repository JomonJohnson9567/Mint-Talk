import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/auth/data/models/user_model.dart';

void main() {
  test('parses host profile fields returned by OTP verification', () {
    final user = UserModel.fromJson(const {
      '_id': 'host-id',
      'phone': '+919876543210',
      'role': 'staff',
      'profileCompleted': true,
      'fullName': 'Aanya Sharma',
      'gender': 'female',
      'dob': '1999-07-09T00:00:00.000Z',
      'audioRate': 30,
      'videoRate': 50,
      'isAudioAllowed': true,
      'isVideoAllowed': false,
    });

    expect(user.id, 'host-id');
    expect(user.fullName, 'Aanya Sharma');
    expect(user.audioRate, 30);
    expect(user.videoRate, 50);
    expect(user.isAudioAllowed, isTrue);
    expect(user.isVideoAllowed, isFalse);
  });
}
