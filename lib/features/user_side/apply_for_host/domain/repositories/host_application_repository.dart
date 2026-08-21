import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_application_entity.dart';
import '../entities/host_application_status_entity.dart';

abstract class HostApplicationRepository {
  Future<Either<Failure, bool>> submitApplication(
    HostApplicationEntity application,
  );
  Future<Either<Failure, String>> uploadImage(String imagePath, String key);
  Future<Either<Failure, HostApplicationStatusEntity>> getApplicationStatus();

  // ── Locally cached application flags ──────────────────────────────────
  // Pure local-storage reads/writes, not network calls, so they aren't
  // wrapped in Either<Failure, T> like the methods above.
  Future<bool> hasAcceptedTerms();
  Future<void> acceptTerms();
  Future<bool> hasSubmittedApplication();
  Future<void> markApplicationSubmitted();
}
