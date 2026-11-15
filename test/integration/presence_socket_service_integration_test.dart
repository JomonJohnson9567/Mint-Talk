// Drives the real PresenceSocketService (real socket_io_client, real
// websocket) against a local socket.io v4 server, to prove the failure modes
// behind the host dashboard's stuck "Reconnect" banner are fixed.
//
// One-time setup:  (cd test/support/socket_io_server && npm install)
// Run just these:  flutter test --tags integration
//
// Skipped automatically when node or the server's node_modules is missing.
@Tags(['integration'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/config/env/env_config.dart';
import 'package:mint_talk/core/services/socket/presence_socket_service.dart';
import 'package:mint_talk/core/utils/token_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockEnvConfig extends Mock implements EnvConfig {}

class _MockTokenManager extends Mock implements TokenManager {}

const _serverDir = 'test/support/socket_io_server';

String? _skipReason() {
  if (!Directory('$_serverDir/node_modules/socket.io').existsSync()) {
    return 'socket.io test server deps missing — run '
        '`(cd $_serverDir && npm install)`';
  }
  try {
    final r = Process.runSync('node', ['--version']);
    if (r.exitCode != 0) return 'node not available';
  } catch (_) {
    return 'node not available';
  }
  return null;
}

/// The local socket.io server process, controlled over stdin/stdout.
class _TestServer {
  final Process _process;
  final StreamController<Map<String, dynamic>> _events =
      StreamController.broadcast();
  final List<Map<String, dynamic>> log = [];
  late final int port;

  _TestServer._(this._process) {
    _process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          try {
            final event = jsonDecode(line) as Map<String, dynamic>;
            log.add(event);
            _events.add(event);
          } catch (_) {}
        });
    _process.stderr.transform(utf8.decoder).listen(stderr.write);
  }

  static Future<_TestServer> start() async {
    final process = await Process.start('node', ['server.js'],
        workingDirectory: _serverDir);
    final server = _TestServer._(process);
    final listening = await server.next('listening');
    server.port = listening['port'] as int;
    return server;
  }

  Future<Map<String, dynamic>> next(
    String event, {
    bool Function(Map<String, dynamic>)? where,
    Duration timeout = const Duration(seconds: 10),
  }) => _events.stream
      .firstWhere((e) => e['event'] == event && (where?.call(e) ?? true))
      .timeout(timeout);

  /// Whether [event] arrives within [within].
  Future<bool> arrives(String event, {required Duration within}) async {
    try {
      await next(event, timeout: within);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  Future<void> send(Map<String, dynamic> cmd) async {
    final ack = next('ack', where: (e) => e['cmd'] == cmd['cmd']);
    _process.stdin.writeln(jsonEncode(cmd));
    await _process.stdin.flush();
    await ack;
  }

  Future<void> mode(String value) => send({'cmd': 'mode', 'value': value});

  Future<void> stop() async {
    await _process.stdin.close();
    _process.kill();
    await _events.close();
  }
}

void main() {
  final skip = _skipReason();

  late _TestServer server;
  late _MockEnvConfig env;
  late _MockTokenManager tokens;
  late PresenceSocketService service;
  late String currentToken;
  late List<bool> statuses;
  late StreamSubscription<bool> statusSub;

  setUpAll(() async {
    if (skip != null) return;
    server = await _TestServer.start();
  });

  tearDownAll(() async {
    if (skip != null) return;
    await server.stop();
  });

  setUp(() async {
    if (skip != null) return;
    await server.mode('accept');
    server.log.clear();
    env = _MockEnvConfig();
    when(() => env.socketUrl).thenReturn('http://127.0.0.1:${server.port}');
    tokens = _MockTokenManager();
    currentToken = 'token-1';
    when(() => tokens.getAccessToken()).thenAnswer((_) => currentToken);
    service = PresenceSocketService(env, tokens);
    statuses = [];
    statusSub = service.connectionStatus.listen(statuses.add);
  });

  tearDown(() async {
    if (skip != null) return;
    await statusSub.cancel();
    service.dispose();
    // Let the server see the close before the next test starts.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });

  Future<void> waitForStatus(bool value) => service.connectionStatus
      .firstWhere((s) => s == value)
      .timeout(const Duration(seconds: 15));

  Future<void> connectAndWait() async {
    final connected = waitForStatus(true);
    service.connect(currentToken);
    await connected;
    expect(service.isConnected, isTrue);
  }

  test('S1: a listener that subscribes after connect sees no event, but '
      'isConnected reports the truth (root cause A precondition)', () async {
    await connectAndWait();

    final late = <bool>[];
    final sub = service.connectionStatus.listen(late.add);
    // A second connect() on a live socket (what Reconnect used to do) takes
    // the "already connected" branch and emits nothing either.
    service.connect(currentToken);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await sub.cancel();

    expect(late, isEmpty);
    expect(service.isConnected, isTrue);
    expect(service.isStalled, isFalse);
  }, skip: skip);

  test('S2: after the server rejects the handshake (non-auth), the next '
      'connect() is not swallowed as a duplicate (root cause B)', () async {
    await server.mode('reject_other');
    final rejected = server.next('handshake', where: (e) => e['accepted'] == false);
    service.connect(currentToken);
    await rejected;
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(service.isConnected, isFalse);
    expect(service.isStalled, isTrue,
        reason: 'socket_io destroyed the socket; nothing will retry it');
    // socket_io_client does not retry a CONNECT_ERROR by itself.
    expect(
      await server.arrives('handshake', within: const Duration(seconds: 3)),
      isFalse,
    );

    await server.mode('accept');
    final connection = server.next('connection');
    final up = waitForStatus(true);
    service.connect(currentToken);
    await connection;
    await up;
    expect(service.isConnected, isTrue);
  }, skip: skip);

  test('S3: an auth rejection refreshes the token and reconnects with the '
      'NEW token', () async {
    await server.mode('reject_auth');
    when(() => tokens.refreshAccessToken()).thenAnswer((_) async {
      currentToken = 'token-2';
      await server.mode('accept');
      return RefreshResult.success;
    });

    final up = waitForStatus(true);
    service.connect(currentToken);
    final accepted = await server.next(
      'handshake',
      where: (e) => e['accepted'] == true,
      timeout: const Duration(seconds: 15),
    );
    await up;

    expect(accepted['token'], 'token-2');
    final rejectedTokens = server.log
        .where((e) => e['event'] == 'handshake' && e['accepted'] == false)
        .map((e) => e['token']);
    expect(rejectedTokens, everyElement('token-1'));
  }, skip: skip);

  test('S4: a server-side disconnect is reported, flagged as stalled (no '
      'library retry), and recovered by connect()', () async {
    await connectAndWait();

    final down = waitForStatus(false);
    await server.send({'cmd': 'kick'});
    await down;

    expect(service.isConnected, isFalse);
    expect(service.isStalled, isTrue);
    expect(
      await server.arrives('handshake', within: const Duration(seconds: 3)),
      isFalse,
      reason: 'socket_io_client must not auto-reconnect after io server '
          'disconnect — that is why the app has to',
    );

    await connectAndWait();
  }, skip: skip);

  test('S5: a transport drop is NOT stalled — the Manager reconnects on its '
      'own and the buffered availability is re-sent', () async {
    await connectAndWait();

    final down = waitForStatus(false);
    final up = service.connectionStatus
        .where((s) => s)
        .first
        .timeout(const Duration(seconds: 20));
    final flushed = server.next(
      'update_availability',
      timeout: const Duration(seconds: 20),
    );
    await server.send({'cmd': 'restart'});
    await down;
    expect(service.isStalled, isFalse,
        reason: 'the Manager is backing off; auto-recovery must not fight it');

    service.updateAvailability(audioAvailable: true, videoAvailable: false);
    await up;
    final payload = (await flushed)['payload'] as Map<String, dynamic>;

    expect(payload, {'audio_available': true, 'video_available': false});
  }, skip: skip);

  test('S6: availability set before the handshake is flushed with the '
      'latest values once connected', () async {
    service.updateAvailability(audioAvailable: false, videoAvailable: false);
    service.updateAvailability(audioAvailable: true, videoAvailable: true);

    final flushed = server.next('update_availability');
    await connectAndWait();
    final payload = (await flushed)['payload'] as Map<String, dynamic>;

    expect(payload, {'audio_available': true, 'video_available': true});
  }, skip: skip);

  test('S7: an app-initiated disconnect (go offline / logout) is never '
      'reported as stalled', () async {
    await connectAndWait();

    service.disconnect();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(service.isConnected, isFalse);
    expect(service.isStalled, isFalse);
    expect(statuses.last, isFalse);

    // And going online again still works.
    await connectAndWait();
    expect(service.isStalled, isFalse);
  }, skip: skip);
}
