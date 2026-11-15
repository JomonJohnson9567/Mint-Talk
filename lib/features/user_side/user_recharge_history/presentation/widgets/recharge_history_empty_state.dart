import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';

/// Shown when the user has no recharges yet; points them back to the plans.
class RechargeHistoryEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;

  const RechargeHistoryEmptyState({super.key, required this.onRefresh});

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
              AppTexts.noRechargesYet,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 8.cw),
            Text(
              AppTexts.noRechargesYetDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.csp,
                color: AppColors.plumMuted,
                height: 1.45,
              ),
            ),
            SizedBox(height: 20.cw),
            // This screen is only pushed from Recharge Plans, so going back
            // lands the user on the plan grid.
            PrimaryButton(
              text: AppTexts.browsePlans,
              width: 180.cw,
              height: 46.cw,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            SizedBox(height: 4.cw),
            TextButton.icon(
              onPressed: onRefresh,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.csp),
              label: Text(
                AppTexts.refresh,
                style: TextStyle(
                  fontSize: 13.5.csp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
