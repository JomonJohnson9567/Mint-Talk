import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Cream-white rounded card used for each content block on the plan
/// details screen.
class PlanDetailSectionCard extends StatelessWidget {
  const PlanDetailSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.cw),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Nunito section heading shown above each [PlanDetailSectionCard].
class PlanDetailSectionTitle extends StatelessWidget {
  const PlanDetailSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 18.csp,
        fontWeight: FontWeight.w800,
        color: AppColors.plumDeep,
      ),
    );
  }
}
