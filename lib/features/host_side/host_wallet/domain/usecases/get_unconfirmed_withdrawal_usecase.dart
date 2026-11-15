import 'package:injectable/injectable.dart';
import '../entities/pending_withdrawal_request.dart';
import '../repositories/host_wallet_repository.dart';

/// The withdrawal still awaiting a server answer, so the wallet can offer a
/// retry with the same `Idempotency-Key` (also after an app restart).
@injectable
class GetUnconfirmedWithdrawalUseCase {
  final HostWalletRepository repository;

  GetUnconfirmedWithdrawalUseCase(this.repository);

  Future<PendingWithdrawalRequest?> call() =>
      repository.getUnconfirmedWithdrawal();
}
