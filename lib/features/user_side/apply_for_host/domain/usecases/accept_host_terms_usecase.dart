import 'package:injectable/injectable.dart';
import '../repositories/host_application_repository.dart';

/// Persists that the user has accepted the host terms & conditions.
@injectable
class AcceptHostTermsUseCase {
  final HostApplicationRepository _repository;

  AcceptHostTermsUseCase(this._repository);

  Future<void> call() => _repository.acceptTerms();
}
