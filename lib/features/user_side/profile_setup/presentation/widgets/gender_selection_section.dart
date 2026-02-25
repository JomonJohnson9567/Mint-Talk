import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/gender_card.dart';

class GenderSelectionSection extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onSelect;

  const GenderSelectionSection({
    super.key,
    required this.selectedGender,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.selectGender,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: GenderCard(
                label: AppTexts.male,
                iconPath: AppAssets.maleIcon,
                isSelected: selectedGender == AppTexts.male,
                onTap: () => onSelect(AppTexts.male),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: GenderCard(
                label: AppTexts.female,
                iconPath: AppAssets.femaleIcon,
                isSelected: selectedGender == AppTexts.female,
                onTap: () => onSelect(AppTexts.female),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
