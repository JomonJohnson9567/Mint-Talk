import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/widgets/mascot_confirm_sheet.dart';

/// "Exit MintTalk?" confirmation shown on back press from the root tab of
/// the user and host shells. Resolves to `true` only when Exit is tapped —
/// Stay, swipe-down, scrim tap and back all keep the app open.
class ExitAppBottomSheet {
  ExitAppBottomSheet._();

  static Future<bool> show(BuildContext context) {
    return MascotConfirmSheet.show(
      context,
      title: AppTexts.exitTitle,
      message: AppTexts.exitSubtitle,
      cancelText: AppTexts.exitStay,
      confirmText: AppTexts.exitConfirm,
    );
  }
}
