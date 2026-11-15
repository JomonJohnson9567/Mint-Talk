import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Back chip + title/subtitle block used at the top of pushed pages,
/// matching the profile page header.
class BackTitleHeader extends StatelessWidget {
  const BackTitleHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.white,
          shape: const CircleBorder(),
          elevation: 0,
          shadowColor: AppColors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 40.cw,
              height: 40.cw,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.csp,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.cw),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 28.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.plumDeep,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 2.cw),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.csp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.plumMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
