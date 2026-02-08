import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/models/screen_metadata.dart';

class ScreenMetadataRegistry {
  static final Map<String, ScreenMetadata> _registry = {
    AppRoutes.welcome: ScreenMetadata(
      backgroundImage: AppAssets.welcomeBackground,
      borderRadius: 32.0,
      backgroundColor: AppColors.tealBackground,
    ),
    AppRoutes.phoneNumber: ScreenMetadata(
      topImage: AppAssets.phoneEntry,
      borderRadius: 30.0,
      imageBottomPosition: 280.0,
      backgroundColor: AppColors.tealBackground,
    ),
    AppRoutes.otpVerification: ScreenMetadata(
      topImage: AppAssets.otpEntry,
      borderRadius: 30.0,
      imageBottomPosition: 280.0,
      backgroundColor: AppColors.tealBackground,
    ),
    AppRoutes.success: ScreenMetadata(
      borderRadius: 50.0,
      backgroundColor: AppColors.tealBackground,
    ),
  };

  static ScreenMetadata? getMetadata(String? routeName) {
    return _registry[routeName];
  }

  static ScreenMetadata getDefaultMetadata() {
    return ScreenMetadata(
      borderRadius: 30.0,
      backgroundColor: AppColors.tealBackground,
    );
  }
}
