import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Headline, subtitle and mascot at the top of the recharge plans screen.
class RechargeHero extends StatelessWidget {
  const RechargeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTexts.rechargeHeadline,
                style: GoogleFonts.nunito(
                  fontSize: 23.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 8.cw),
              Text(
                AppTexts.rechargeSubtitle,
                style: TextStyle(
                  fontSize: 12.5.csp,
                  color: AppColors.plumMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6.cw),
        Image.asset(
          AppAssets.rechargeMascot,
          width: 116.cw,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
