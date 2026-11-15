import 'package:equatable/equatable.dart';

enum AppUpdateAvailability {
  /// No newer build on the Play Store — or the check couldn't run (iOS,
  /// debug/sideloaded build, Play Store missing, offline).
  none,

  /// A newer build is live on the Play Store.
  available,

  /// A flexible update was downloaded earlier and is waiting to be installed.
  downloaded,
}

class AppUpdateCheck extends Equatable {
  final AppUpdateAvailability availability;

  /// Whether Play allows a flexible (background download) update right now.
  /// When `false`, the only way to update is opening the store listing.
  final bool flexibleAllowed;

  final int? availableVersionCode;

  const AppUpdateCheck({
    required this.availability,
    this.flexibleAllowed = false,
    this.availableVersionCode,
  });

  static const none = AppUpdateCheck(availability: AppUpdateAvailability.none);

  @override
  List<Object?> get props => [availability, flexibleAllowed, availableVersionCode];
}

/// Detects newer Play Store builds and runs Google Play's flexible in-app
/// update (Android only).
///
/// Nothing here throws: any failure is logged and reported as "no update" /
/// `false`, so a broken update check can never break the app.
abstract interface class IAppUpdateService {
  Future<AppUpdateCheck> checkForUpdate();

  /// Fires once Play actually starts downloading (i.e. the user accepted
  /// Play's update dialog).
  Stream<void> get downloadStarted;

  /// Shows Play's update dialog and downloads in the background. Resolves
  /// `true` once the download has finished, `false` if the user declined or
  /// it failed.
  Future<bool> startFlexibleUpdate();

  /// Installs the downloaded update — Play restarts the app.
  Future<void> completeFlexibleUpdate();

  /// Fallback when a flexible update isn't allowed.
  Future<void> openStoreListing();
}
