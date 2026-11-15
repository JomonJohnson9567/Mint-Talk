import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_application_entity.dart';
import '../entities/host_application_status_entity.dart';

abstract class HostApplicationRepository {
  Future<Either<Failure, bool>> submitApplication(
    HostApplicationEntity application,
  );
  /// Uploads a selfie to the private verification endpoint and returns its
  /// `verificationPhotoId`.
  Future<Either<Failure, String>> uploadVerificationPhoto(String imagePath);
  Future<Either<Failure, HostApplicationStatusEntity>> getApplicationStatus();

  /// Activates host status for an approved application — the user's role
  /// flips to host and a fresh access token carrying that role is issued
  /// and persisted, so the caller can navigate straight to the Host
  /// dashboard without a manual logout/login.
  Future<Either<Failure, void>> joinAsHost();

  // ── Locally cached application flags ──────────────────────────────────
  // Pure local-storage reads/writes, not network calls, so they aren't
  // wrapped in Either<Failure, T> like the methods above.
  Future<bool> hasAcceptedTerms();
  Future<void> acceptTerms();
  Future<bool> hasSubmittedApplication();
  Future<void> markApplicationSubmitted();
}
