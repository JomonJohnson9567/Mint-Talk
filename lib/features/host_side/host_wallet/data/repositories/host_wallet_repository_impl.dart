import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/datasources/pending_withdrawal_local_datasource.dart';
import 'package:mint_talk/features/host_side/host_wallet/data/models/host_wallet_models.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/pending_withdrawal_request.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/repositories/host_wallet_repository.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: HostWalletRepository)
class HostWalletRepositoryImpl implements HostWalletRepository {
  final HostWalletRemoteDataSource remoteDataSource;
  final PendingWithdrawalLocalDataSource pendingDataSource;

  HostWalletRepositoryImpl(this.remoteDataSource, this.pendingDataSource);

  /// Waits before each automatic retry of a withdrawal whose response never
  /// arrived. Two retries, then the host gets a manual Retry.
  @visibleForTesting
  static List<Duration> retryDelays = const [
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  /// An unconfirmed request older than this is dropped rather than replayed:
  /// the server's idempotency record may have expired by then, and replaying
  /// a key it no longer remembers could create a second withdrawal.
  @visibleForTesting
  static Duration unconfirmedMaxAge = const Duration(hours: 24);

  @visibleForTesting
  static String Function() generateIdempotencyKey = () => const Uuid().v4();

  @visibleForTesting
  static DateTime Function() now = DateTime.now;

  @override
  Future<Either<Failure, HostWalletOverviewEntity>> getWalletOverview({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final model = await remoteDataSource.getWalletOverview(
        page: page,
        limit: limit,
      );
      return Right(model);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'HostWalletRepositoryImpl: request error loading wallet overview: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(
        mapDioExceptionToFailure(
          e,
          fallbackMessage: 'Failed to load wallet overview',
        ),
      );
    } catch (e, stackTrace) {
      appLogger.e(
        'HostWalletRepositoryImpl: unknown error loading wallet overview: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<PendingWithdrawalRequest?> getUnconfirmedWithdrawal() async {
    final pending = await pendingDataSource.read();
    if (pending == null) return null;
    if (now().difference(pending.createdAt) > unconfirmedMaxAge) {
      appLogger.w(
        'HostWalletRepositoryImpl: dropping unconfirmed withdrawal older '
        'than ${unconfirmedMaxAge.inHours}h',
      );
      await pendingDataSource.clear();
      return null;
    }
    return pending;
  }

  @override
  Future<Either<Failure, HostWithdrawalEntryEntity>> requestWithdrawal(
    HostWithdrawalRequestParams request,
  ) async {
    final pending = await _pendingRequestFor(request);
    final model = HostWithdrawalRequestModel(
      amount: pending.amount,
      payoutMethod: pending.payoutMethod,
    );

    Either<Failure, HostWithdrawalEntryEntity> result;
    var attempt = 0;
    while (true) {
      result = await _sendOnce(model, pending.idempotencyKey);
      final failure = result.fold<Failure?>((f) => f, (_) => null);
      if (failure == null ||
          !_isRetryable(failure) ||
          attempt >= retryDelays.length) {
        break;
      }
      appLogger.w(
        'HostWalletRepositoryImpl: withdrawal unconfirmed, retrying with the '
        'same key (attempt ${attempt + 2})',
      );
      await Future<void>.delayed(retryDelays[attempt]);
      attempt++;
    }

    // Keep the key only while the outcome is genuinely unknown. A response
    // either way — success or the server's explicit rejection — settles it.
    final settled = result.fold(_isDefinitiveRejection, (_) => true);
    if (settled) await pendingDataSource.clear();
    return result;
  }

  /// Reuses the stored key when [request] repeats the unconfirmed body
  /// exactly (a retry); anything else is a genuinely new withdrawal.
  Future<PendingWithdrawalRequest> _pendingRequestFor(
    HostWithdrawalRequestParams request,
  ) async {
    final existing = await getUnconfirmedWithdrawal();
    if (existing != null &&
        existing.hasSameBody(
          amount: request.amount,
          payoutMethod: request.payoutMethod,
        )) {
      return existing;
    }

    final fresh = PendingWithdrawalRequest(
      idempotencyKey: generateIdempotencyKey(),
      amount: request.amount,
      payoutMethod: request.payoutMethod,
      createdAt: now(),
    );
    try {
      // Saved before sending, so a kill mid-request still leaves the key.
      await pendingDataSource.save(fresh);
    } catch (e) {
      // In-session retries still reuse the key; only restart recovery is lost.
      appLogger.e('HostWalletRepositoryImpl: could not persist key: $e');
    }
    return fresh;
  }

  Future<Either<Failure, HostWithdrawalEntryEntity>> _sendOnce(
    HostWithdrawalRequestModel model,
    String idempotencyKey,
  ) async {
    try {
      final entry = await remoteDataSource.requestWithdrawal(
        model,
        idempotencyKey: idempotencyKey,
      );
      return Right(entry);
    } on DioException catch (e) {
      // Deliberately no request body/headers in the log.
      appLogger.e(
        'HostWalletRepositoryImpl: withdrawal request failed '
        '(${e.type.name}, ${e.response?.statusCode})',
      );
      return Left(
        mapDioExceptionToFailure(
          e,
          fallbackMessage: 'Failed to submit withdrawal request',
        ),
      );
    } catch (e) {
      appLogger.e('HostWalletRepositoryImpl: withdrawal request error: $e');
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  /// No response reached us (timeout / dropped connection) or a gateway
  /// error — the request may or may not have been created.
  static bool _isRetryable(Failure failure) =>
      failure is NetworkFailure ||
      (failure is ServerFailure &&
          const {502, 503, 504}.contains(failure.statusCode));

  /// The server answered and refused the request (validation, conflict,
  /// ineligible) — it definitely wasn't created, so the key is done.
  static bool _isDefinitiveRejection(Failure failure) {
    if (failure is ValidationFailure || failure is UnauthorizedFailure) {
      return true;
    }
    final status = failure.statusCode;
    return failure is ServerFailure &&
        status != null &&
        status >= 400 &&
        status < 500 &&
        status != 408 &&
        status != 429;
  }
}
