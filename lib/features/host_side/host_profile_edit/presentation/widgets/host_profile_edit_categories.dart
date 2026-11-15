import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../cubit/host_profile_edit_cubit.dart';

/// Hint + `n/4` counter over a wrap of pill chips. Once the cap is hit the
/// unselected chips dim, since [HostProfileEditCubit.toggleCategory] ignores
/// further additions.
class HostProfileEditCategories extends StatelessWidget {
  const HostProfileEditCategories({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    const max = HostProfileEditCubit.maxCategories;
    final isFull = selected.length >= max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                AppTexts.categoriesHint,
                style: TextStyle(
                  fontSize: 12.5.csp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.plumMuted,
                ),
              ),
            ),
            SizedBox(width: 8.cw),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.cw, vertical: 4.cw),
              decoration: BoxDecoration(
                color: AppColors.popularCardBg,
                borderRadius: BorderRadius.circular(12.cw),
              ),
              child: Text(
                '${selected.length}/$max',
                style: TextStyle(
                  fontSize: 12.csp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.cw),
        Wrap(
          spacing: 8.cw,
          runSpacing: 8.cw,
          children: [
            for (final category in AppTexts.hostCategories)
              _CategoryChip(
                label: category,
                isSelected: selected.contains(category),
                isDimmed: isFull && !selected.contains(category),
                onTap: () => onToggle(category),
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.isDimmed,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.cw);
    final foreground = isSelected ? AppColors.white : AppColors.plumDeep;

    return Opacity(
      opacity: isDimmed ? 0.45 : 1,
      child: Material(
        color: isSelected ? AppColors.primaryColor : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.lavenderBorder,
            width: 1.4.cw,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.fromLTRB(
              isSelected ? 10.cw : 14.cw,
              8.cw,
              14.cw,
              8.cw,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_rounded, size: 15.csp, color: foreground),
                  SizedBox(width: 4.cw),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.csp,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
