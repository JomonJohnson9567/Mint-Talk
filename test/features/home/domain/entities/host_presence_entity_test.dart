// Regression test for a host shown as "On Call" while offline: GET /hosts
// returned `status: offline, state: offline, busy: true` (a stale busy flag
// left over from an earlier call), and every UI check let `busy` win.
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/home/data/models/host_presence_dto.dart';

void main() {
  bool isOnCall(Map<String, dynamic> json) =>
      HostPresenceDto.fromJson({'userId': 'h1', ...json}).toEntity().isOnCall;

  bool isAvailable(Map<String, dynamic> json) => HostPresenceDto.fromJson({
        'userId': 'h1',
        'audio_available': true,
        ...json,
      }).toEntity().isAvailableForCalls;

  group('HostPresenceEntity.isOnCall', () {
    test('stale busy flag on an offline host is not "on call"', () {
      expect(
        isOnCall({'status': 'offline', 'state': 'offline', 'busy': true}),
        isFalse,
      );
      expect(isOnCall({'status': 'offline', 'busy': true}), isFalse);
    });

    test('stale state "busy" on an offline host is not "on call"', () {
      expect(isOnCall({'status': 'offline', 'state': 'busy'}), isFalse);
      expect(
        isOnCall({'status': 'offline', 'state': 'busy', 'busy': true}),
        isFalse,
      );
    });

    test('a connected host whose state is not busy ignores a stale busy flag', () {
      expect(isOnCall({'status': 'online', 'state': 'online', 'busy': true}), isFalse);
    });

    test('state "busy" is on call', () {
      expect(isOnCall({'status': 'online', 'state': 'busy'}), isTrue);
    });

    test('falls back to busy flag while connected when state is absent', () {
      expect(isOnCall({'status': 'online', 'busy': true}), isTrue);
      expect(isOnCall({'status': 'online', 'busy': false}), isFalse);
    });
  });

  group('HostPresenceEntity.isAvailableForCalls', () {
    test('online, not busy, opted in → available', () {
      expect(isAvailable({'status': 'online', 'state': 'online'}), isTrue);
    });

    test('on call → not available', () {
      expect(isAvailable({'status': 'online', 'state': 'busy'}), isFalse);
      expect(isAvailable({'status': 'online', 'busy': true}), isFalse);
    });

    test('offline → not available', () {
      expect(
        isAvailable({'status': 'offline', 'state': 'offline', 'busy': true}),
        isFalse,
      );
      expect(isAvailable({'status': 'offline', 'state': 'busy'}), isFalse);
    });
  });
}
