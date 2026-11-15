import 'package:in_app_update/in_app_update.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/core/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'i_app_update_service.dart';

/// Google Play In-App Updates via `in_app_update`. Only works for builds
/// installed from the Play Store (incl. internal testing / internal app
/// sharing) — debug and sideloaded builds get an "app not owned" error,
/// which is logged and treated as "no update".
@LazySingleton(as: IAppUpdateService)
class AppUpdateService implements IAppUpdateService {
  static const _packageName = 'com.minttalk.app';

  @override
  Future<AppUpdateCheck> checkForUpdate() async {
    if (!PlatformUtils.isAndroid) return AppUpdateCheck.none;
    try {
      final info = await InAppUpdate.checkForUpdate();
      appLogger.d('[AppUpdate] $info');
      if (info.installStatus == InstallStatus.downloaded) {
        return AppUpdateCheck(
          availability: AppUpdateAvailability.downloaded,
          availableVersionCode: info.availableVersionCode,
        );
      }
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        return AppUpdateCheck(
          availability: AppUpdateAvailability.available,
          flexibleAllowed: info.flexibleUpdateAllowed,
          availableVersionCode: info.availableVersionCode,
        );
      }
    } catch (e) {
      appLogger.w('[AppUpdate] checkForUpdate failed: $e');
    }
    return AppUpdateCheck.none;
  }

  @override
  Stream<void> get downloadStarted => InAppUpdate.installUpdateListener
      .where((status) => status == InstallStatus.downloading)
      .take(1);

  @override
  Future<bool> startFlexibleUpdate() async {
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      appLogger.d('[AppUpdate] flexible update result: $result');
      return result == AppUpdateResult.success;
    } catch (e) {
      appLogger.w('[AppUpdate] startFlexibleUpdate failed: $e');
      return false;
    }
  }

  @override
  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      appLogger.w('[AppUpdate] completeFlexibleUpdate failed: $e');
    }
  }

  @override
  Future<void> openStoreListing() async {
    final market = Uri.parse('market://details?id=$_packageName');
    final web = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_packageName',
    );
    try {
      final opened = await launchUrl(
        market,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      appLogger.w('[AppUpdate] openStoreListing failed: $e');
      try {
        await launchUrl(web, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}
