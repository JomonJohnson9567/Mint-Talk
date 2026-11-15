import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/mascot_confirm_sheet.dart';

class SettingsActionBottomSheetPresenter {
  SettingsActionBottomSheetPresenter._();

  static Future<void> showLogout(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await MascotConfirmSheet.show(
      context,
      title: AppTexts.logoutTitle,
      message: AppTexts.logoutDescription,
      cancelText: AppTexts.stayLoggedIn,
      confirmText: AppTexts.logout,
    );
    if (confirmed) onConfirm();
  }

  static Future<void> showDeleteAccount(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await MascotConfirmSheet.show(
      context,
      title: AppTexts.deleteAccountTitle,
      message: AppTexts.deleteAccountDescription,
      cancelText: AppTexts.keepAccount,
      confirmText: AppTexts.delete,
      // Same danger accent as the "Delete account" row in settings.
      confirmColor: AppColors.linkMagenta,
      warning: AppTexts.deleteAccountWarning,
    );
    if (confirmed) onConfirm();
  }
}
