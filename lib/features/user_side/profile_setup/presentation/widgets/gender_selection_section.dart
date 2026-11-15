import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/gender_card.dart';

class GenderSelectionSection extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onSelect;
  final String? errorText;

  const GenderSelectionSection({
    super.key,
    required this.selectedGender,
    required this.onSelect,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            AppTexts.selectGender,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
            ),
          ),
        ),
        SizedBox(height: 10.h),
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
            SizedBox(width: 14.w),
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
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 16.w),
            child: Text(
              errorText!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}
