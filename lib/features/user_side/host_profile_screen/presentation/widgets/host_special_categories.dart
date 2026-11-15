import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Nunito section title above a cream card of topic pills.
class HostSpecialCategories extends StatelessWidget {
  const HostSpecialCategories({super.key});

  static const _categories = [
    (Icons.favorite_rounded, AppTexts.empathy),
    (Icons.volunteer_activism_rounded, AppTexts.compassion),
    (Icons.people_alt_rounded, AppTexts.loneliness),
    (Icons.psychology_rounded, AppTexts.problemSolving),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.cw),
          child: Text(
            AppTexts.specialCategories,
            style: GoogleFonts.nunito(
              fontSize: 18.csp,
              fontWeight: FontWeight.w800,
              color: AppColors.plumDeep,
            ),
          ),
        ),
        SizedBox(height: 10.cw),
        Container(
          padding: EdgeInsets.all(14.cw),
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
          child: Wrap(
            spacing: 8.cw,
            runSpacing: 8.cw,
            children: [
              for (final (icon, label) in _categories)
                _CategoryPill(icon: icon, label: label),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.cw, vertical: 8.cw),
      decoration: BoxDecoration(
        color: AppColors.popularCardBg,
        borderRadius: BorderRadius.circular(20.cw),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.csp, color: AppColors.primaryColor),
          SizedBox(width: 6.cw),
          // Flexible so the long "problem solving" label wraps instead of
          // overflowing on narrow phones.
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.csp,
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
