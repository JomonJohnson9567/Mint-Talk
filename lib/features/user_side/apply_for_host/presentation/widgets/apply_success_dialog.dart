import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Shown once the application is accepted by the backend. The phone mascot's
/// background is the same cream as [AppColors.creamBackground], so it sits on
/// a cream panel without needing a mask.
class ApplySuccessDialog extends StatelessWidget {
  const ApplySuccessDialog({super.key, required this.hostContext});

  /// The screen's context, used to replace the route once the dialog closes.
  final BuildContext hostContext;

  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: ApplySuccessDialog(hostContext: context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardWhite,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.cw),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.cw)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: AppColors.creamBackground,
            child: Padding(
              padding: EdgeInsets.only(top: 12.cw),
              child: Image.asset(
                AppAssets.hostSuccessMascot,
                height: 170.cw,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22.cw, 20.cw, 22.cw, 22.cw),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTexts.applicationSubmitted,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 22.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                  ),
                ),
                SizedBox(height: 8.cw),
                Text(
                  AppTexts.applicationSubmittedMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5.csp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.plumMuted,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: 22.cw),
                PrimaryButton(
                  text: AppTexts.checkStatus,
                  height: 52.cw,
                  textStyle: GoogleFonts.nunito(
                    fontSize: 16.csp,
                    fontWeight: FontWeight.w800,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // dismiss dialog
                    Navigator.of(
                      hostContext,
                    ).pushReplacementNamed(AppRoutes.hostApplicationStatus);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
