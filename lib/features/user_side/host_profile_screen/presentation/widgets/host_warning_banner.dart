import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Warm peach card reminding the user of the conduct rules.
class HostWarningBanner extends StatelessWidget {
  const HostWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.cw),
      decoration: BoxDecoration(
        color: AppColors.audioCardBg,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(
          color: AppColors.audioAccent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.cw,
            height: 40.cw,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 21.csp,
              color: AppColors.audioAccent,
            ),
          ),
          SizedBox(width: 12.cw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.warning,
                  style: GoogleFonts.nunito(
                    fontSize: 15.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                  ),
                ),
                SizedBox(height: 2.cw),
                Text(
                  AppTexts.warningMessage,
                  style: TextStyle(
                    fontSize: 12.5.csp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.plumMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
