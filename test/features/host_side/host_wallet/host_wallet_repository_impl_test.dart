import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/datasources/pending_withdrawal_local_datasource.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/models/host_wallet_models.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/repositories/host_wallet_repository_impl.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/pending_withdrawal_request.dart';

/// Records every POST (key + body) and answers from a scripted queue.
class _FakeRemote implements HostWalletRemoteDataSource {
  final List<Object> responses;
  final calls = <({String key, Map<String, dynamic> body})>[];

  _FakeRemote(this.responses);

  @override
  Future<HostWithdrawalEntryModel> requestWithdrawal(
    HostWithdrawalRequestModel request, {
    required String idempotencyKey,
  }) async {
    calls.add((key: idempotencyKey, body: request.toJson()));
    final next = responses.removeAt(0);
    if (next is DioException) throw next;
    return next as HostWithdrawalEntryModel;
  }

  @override
  Future<HostWalletOverviewModel> getWalletOverview({
    int page = 1,
    int limit = 20,
  }) => throw UnimplementedError();
}

/// In-memory stand-in for secure storage; survives "restarts" by being
/// handed to a fresh repository.
class _FakePending implements PendingWithdrawalLocalDataSource {
  PendingWithdrawalRequest? stored;

  @override
  Future<PendingWithdrawalRequest?> read() async => stored;

  @override
  Future<void> save(PendingWithdrawalRequest request) async => stored = request;

  @override
  Future<void> clear() async => stored = null;
}

DioException _timeout() => DioException(
  requestOptions: RequestOptions(),
  type: DioExceptionType.receiveTimeout,
  error: const NetworkException(message: 'timeout'),
);

DioException _status(int code, String message) => DioException(
  requestOptions: RequestOptions(),
  type: DioExceptionType.badResponse,
  error: ServerException(message: message, statusCode: code),
);

final _ok = HostWithdrawalEntryModel(
  id: 'w1',
  amount: 100,
  payoutMethod: PayoutMethod.bankTransfer,
  status: WithdrawalStatus.pending,
  createdAt: DateTime(2026, 11, 10),
);

const _request = HostWithdrawalRequestParams(
  amount: 100,
  payoutMethod: PayoutMethod.bankTransfer,
);

void main() {
  late _FakePending pending;
  var keyCounter = 0;

  setUp(() {
    pending = _FakePending();
    keyCounter = 0;
    HostWalletRepositoryImpl.retryDelays = const [Duration.zero, Duration.zero];
    HostWalletRepositoryImpl.generateIdempotencyKey = () =>
        'key-${++keyCounter}';
    HostWalletRepositoryImpl.now = () => DateTime(2026, 11, 10, 12);
  });

  test('success sends one request with a key and clears it', () async {
    final remote = _FakeRemote([_ok]);
    final repo = HostWalletRepositoryImpl(remote, pending);

    final result = await repo.requestWithdrawal(_request);

    expect(result.isRight(), isTrue);
    expect(remote.calls.single.key, 'key-1');
    expect(remote.calls.single.body, {
      'amount': 100,
      'payoutMethod': 'bank_transfer',
    });
    expect(pending.stored, isNull);
  });

  test('timeouts retry with the same key and the same body', () async {
    final remote = _FakeRemote([_timeout(), _timeout(), _ok]);
    final repo = HostWalletRepositoryImpl(remote, pending);

    final result = await repo.requestWithdrawal(_request);

    expect(result.isRight(), isTrue);
    expect(remote.calls, hasLength(3));
    expect(remote.calls.map((c) => c.key).toSet(), {'key-1'});
    for (final call in remote.calls) {
      expect(call.body, {'amount': 100, 'payoutMethod': 'bank_transfer'});
    }
    expect(pending.stored, isNull);
  });

  test('after retries are exhausted the key is kept for later', () async {
    final remote = _FakeRemote([_timeout(), _timeout(), _timeout()]);
    final repo = HostWalletRepositoryImpl(remote, pending);

    final result = await repo.requestWithdrawal(_request);

    expect(result.fold((f) => f, (_) => null), isA<NetworkFailure>());
    expect(pending.stored?.idempotencyKey, 'key-1');
  });

  test('a restart resumes the stored key for the same body', () async {
    await HostWalletRepositoryImpl(
      _FakeRemote([_timeout(), _timeout(), _timeout()]),
      pending,
    ).requestWithdrawal(_request);

    // New repository instance = app restarted; storage persisted.
    final remote = _FakeRemote([_ok]);
    final result = await HostWalletRepositoryImpl(
      remote,
      pending,
    ).requestWithdrawal(_request);

    expect(result.isRight(), isTrue);
    expect(remote.calls.single.key, 'key-1');
    expect(pending.stored, isNull);
  });

  test('a different body is a new withdrawal with a new key', () async {
    await HostWalletRepositoryImpl(
      _FakeRemote([_timeout(), _timeout(), _timeout()]),
      pending,
    ).requestWithdrawal(_request);

    final remote = _FakeRemote([_ok]);
    await HostWalletRepositoryImpl(remote, pending).requestWithdrawal(
      const HostWithdrawalRequestParams(
        amount: 150,
        payoutMethod: PayoutMethod.bankTransfer,
      ),
    );

    expect(remote.calls.single.key, 'key-2');
  });

  test('a 4xx rejection is not retried and clears the key', () async {
    final remote = _FakeRemote([_status(409, 'Pending withdrawal exists')]);
    final repo = HostWalletRepositoryImpl(remote, pending);

    final result = await repo.requestWithdrawal(_request);

    final failure = result.fold((f) => f, (_) => null);
    expect(failure?.message, 'Pending withdrawal exists');
    expect(remote.calls, hasLength(1));
    expect(pending.stored, isNull);
  });

  test('a 500 is not auto-retried but the key is kept', () async {
    final remote = _FakeRemote([_status(500, 'boom')]);
    final repo = HostWalletRepositoryImpl(remote, pending);

    await repo.requestWithdrawal(_request);

    expect(remote.calls, hasLength(1));
    expect(pending.stored?.idempotencyKey, 'key-1');
  });

  test('stale unconfirmed requests are dropped, not replayed', () async {
    pending.stored = PendingWithdrawalRequest(
      idempotencyKey: 'old',
      amount: 100,
      payoutMethod: PayoutMethod.bankTransfer,
      createdAt: DateTime(2026, 11, 8),
    );
    final remote = _FakeRemote([_ok]);
    final repo = HostWalletRepositoryImpl(remote, pending);

    expect(await repo.getUnconfirmedWithdrawal(), isNull);
    await repo.requestWithdrawal(_request);
    expect(remote.calls.single.key, 'key-1');
  });
}
