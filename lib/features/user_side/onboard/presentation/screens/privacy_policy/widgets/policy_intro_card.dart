import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/constants/terms_and_conditions.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Peach card with the MintTalk mascot, the read-carefully note and the
/// operator / contact details from the terms cover page.
class PolicyIntroCard extends StatelessWidget {
  const PolicyIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greetingBanner,
        borderRadius: BorderRadius.circular(20.r),
      ),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.fromLTRB(16.cw, 4.cw, 8.cw, 16.cw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.termsIntroTitle,
                      style: GoogleFonts.nunito(
                        fontSize: 20.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    SizedBox(height: 4.cw),
                    Text(
                      AppTexts.termsIntroBody,
                      style: TextStyle(
                        fontSize: 13.csp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.plumMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              // The mascot image is opaque — its background matches
              // AppColors.greetingBanner, so it reads as part of the card.
              Image.asset(
                AppAssets.homeMascot,
                height: 76.cw,
                fit: BoxFit.contain,
              ),
            ],
          ),
          SizedBox(height: 8.cw),
          const _DetailRow(
            label: AppTexts.termsOperatorLabel,
            value: TermsAndConditions.operator,
          ),
          SizedBox(height: 6.cw),
          const _DetailRow(
            label: AppTexts.termsContactLabel,
            value: TermsAndConditions.contact,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.cw),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72.cw,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.csp,
                fontWeight: FontWeight.w600,
                color: AppColors.plumMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.csp,
                fontWeight: FontWeight.w700,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
