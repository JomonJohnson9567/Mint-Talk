import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Shown when the plan couldn't be loaded; offers a retry.
class PlanDetailFailure extends StatelessWidget {
  const PlanDetailFailure({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssets.rechargeMascot, width: 130.cw),
            SizedBox(height: 16.cw),
            Text(
              AppTexts.unableToLoadPlan,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 8.cw),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.csp,
                color: AppColors.plumMuted,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.cw),
            PrimaryButton(
              text: 'Retry',
              width: 160.cw,
              height: 46.cw,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
