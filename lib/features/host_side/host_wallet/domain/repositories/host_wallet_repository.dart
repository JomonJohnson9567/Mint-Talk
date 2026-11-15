import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_wallet_entities.dart';
import '../entities/pending_withdrawal_request.dart';

abstract class HostWalletRepository {
  Future<Either<Failure, HostWalletOverviewEntity>> getWalletOverview({
    int page = 1,
    int limit = 20,
  });

  /// Sends a withdrawal with an `Idempotency-Key`. A request with the same
  /// body as an unconfirmed earlier one reuses that key; anything else gets
  /// a fresh UUID. Timeouts are retried with the same key and body.
  Future<Either<Failure, HostWithdrawalEntryEntity>> requestWithdrawal(
    HostWithdrawalRequestParams request,
  );

  /// The withdrawal whose result is still unknown (it timed out or the app
  /// was closed mid-request), if any.
  Future<PendingWithdrawalRequest?> getUnconfirmedWithdrawal();
}
