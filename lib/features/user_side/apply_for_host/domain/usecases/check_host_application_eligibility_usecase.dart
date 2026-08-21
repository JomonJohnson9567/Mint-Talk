import 'package:injectable/injectable.dart';
import '../repositories/host_application_repository.dart';

class HostApplicationEligibility {
  final bool hasSubmittedApplication;
  final bool hasAcceptedTerms;

  const HostApplicationEligibility({
    required this.hasSubmittedApplication,
    required this.hasAcceptedTerms,
  });
}

/// Checks the locally cached host-application flags (terms accepted /
/// application already submitted) used to route the "Become a Host" entry
/// point without a network round-trip.
@injectable
class CheckHostApplicationEligibilityUseCase {
  final HostApplicationRepository _repository;

  CheckHostApplicationEligibilityUseCase(this._repository);

  Future<HostApplicationEligibility> call() async {
    return HostApplicationEligibility(
      hasSubmittedApplication: await _repository.hasSubmittedApplication(),
      hasAcceptedTerms: await _repository.hasAcceptedTerms(),
    );
  }
}
