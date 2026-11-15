import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Nunito heading shown above each section card.
class ApplySectionTitle extends StatelessWidget {
  const ApplySectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.cw),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 18.csp,
          fontWeight: FontWeight.w800,
          color: AppColors.plumDeep,
        ),
      ),
    );
  }
}

/// Cream-white rounded card wrapping a group of form inputs.
class ApplySectionCard extends StatelessWidget {
  const ApplySectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.cw),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(color: AppColors.profileDivider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
