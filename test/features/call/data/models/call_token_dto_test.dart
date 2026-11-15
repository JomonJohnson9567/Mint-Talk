import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/call/data/models/call_token_dto.dart';

void main() {
  test('parses the documented /token response', () {
    final dto = CallTokenDto.fromJson({
      'success': true,
      'message': 'RTC token issued',
      'data': {
        'callId': '660d1f2a9b3c4d5e6f708192',
        'agoraChannel': 'call_660d',
        'agoraUid': 1,
        'token': 'rtc-abc',
        'tokenExpiresInSeconds': 3600,
      },
    });

    expect(dto.token, 'rtc-abc');
    expect(dto.channelName, 'call_660d');
    expect(dto.uid, 1);
    expect(dto.expiresInSeconds, 3600);
  });

  test('still accepts one legacy alias per field', () {
    final dto = CallTokenDto.fromJson({
      'agoraToken': 'rtc-xyz',
      'channelName': 'call_1',
      'uid': '2',
      'expiresInSeconds': 120.0,
    });

    expect(dto.token, 'rtc-xyz');
    expect(dto.channelName, 'call_1');
    expect(dto.uid, 2);
    expect(dto.expiresInSeconds, 120);
  });

  test('leaves the token empty when the response has none', () {
    expect(CallTokenDto.fromJson({'data': {}}).token, isEmpty);
  });
}
