// Regression test reproducing the reported bug: a call's summary showed
// duration correctly but billedMinutes/totalPointsDebited stuck at 0. The
// most likely cause found on inspection: if the backend serializes these
// numeric fields as JSON doubles (e.g. "120.0" instead of "120" — common
// for MongoDB/JS-backed APIs) the old parsing (`int.tryParse(x.toString())`)
// silently returned null for any decimal-point string, defaulting to 0 —
// while `duration`, if it happened to arrive as a clean integer, parsed
// fine. That's exactly the asymmetry that was reported.
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/features/user_side/call/data/models/call_session_dto.dart';

void main() {
  test(
    'parses duration/billedMinutes/totalPointsDebited correctly when the '
    'backend sends them as whole-number doubles, not just plain ints',
    () {
      final dto = CallSessionDto.fromJson({
        'data': {
          'callId': 'call-1',
          'status': 'ended',
          'callType': 'video',
          'duration': 240,
          'billedMinutes': 4.0,
          'totalPointsDebited': 480.0,
          'endReason': 'caller_ended_call',
        },
      });

      final entity = dto.toEntity();

      expect(entity.duration, 240);
      expect(entity.billedUnits, 4);
      expect(entity.totalPointsDebited, 480);
    },
  );

  test(
    'rounds a genuinely fractional billedMinutes instead of dropping it to 0',
    () {
      final dto = CallSessionDto.fromJson({
        'data': {
          'callId': 'call-1',
          'status': 'ended',
          'callType': 'audio',
          'duration': 125,
          'billedMinutes': 2.0833333,
          'totalPointsDebited': 120,
          'endReason': 'caller_ended_call',
        },
      });

      final entity = dto.toEntity();

      expect(entity.duration, 125);
      expect(entity.billedUnits, 2);
      expect(entity.totalPointsDebited, 120);
    },
  );

  test('still parses correctly for the plain-int shape the docs show', () {
    final dto = CallSessionDto.fromJson({
      'data': {
        'callId': 'call-1',
        'status': 'ended',
        'callType': 'audio',
        'duration': 125,
        'billedMinutes': 2,
        'totalPointsDebited': 120,
        'endReason': 'caller_ended_call',
      },
    });

    final entity = dto.toEntity();

    expect(entity.duration, 125);
    expect(entity.billedUnits, 2);
    expect(entity.totalPointsDebited, 120);
  });

  test('reads billedUnits (per-second or per-minute) ahead of the legacy key', () {
    final entity = CallSessionDto.fromJson({
      'data': {
        'callId': 'call-1',
        'status': 'ended',
        'callType': 'video',
        'duration': 125,
        'billedUnits': 125,
        'billedMinutes': 3,
        'totalPointsDebited': 7500,
      },
    }).toEntity();

    expect(entity.billedUnits, 125);
  });

  test('parses initiate/accept credentials and activeAt', () {
    final entity = CallSessionDto.fromJson({
      'data': {
        'callId': 'call-1',
        'status': 'active',
        'callType': 'audio',
        'agoraChannel': 'call_1',
        'agoraUid': 2,
        'token': 'rtc-host',
        'tokenExpiresInSeconds': 3600,
        'activeAt': '2026-10-17T09:12:30.000Z',
      },
    }).toEntity();

    expect(entity.agoraChannel, 'call_1');
    expect(entity.agoraUid, 2);
    expect(entity.agoraToken, 'rtc-host');
    expect(entity.tokenExpiresInSeconds, 3600);
    expect(entity.activeAt, DateTime.utc(2026, 10, 17, 9, 12, 30).toLocal());
  });
}
