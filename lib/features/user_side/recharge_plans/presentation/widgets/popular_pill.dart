import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// "Popular ★" pill. [inverted] swaps to a white pill for plum backgrounds.
class PopularPill extends StatelessWidget {
  const PopularPill({super.key, this.inverted = false});

  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final background = inverted ? AppColors.white : AppColors.primaryColor;
    final foreground = inverted ? AppColors.primaryColor : AppColors.white;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.cw, vertical: 3.cw),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppTexts.popular,
            style: TextStyle(
              fontSize: 10.5.csp,
              fontWeight: FontWeight.w700,
              color: foreground,
              height: 1.2,
            ),
          ),
          SizedBox(width: 3.cw),
          Icon(Icons.star_rounded, size: 12.csp, color: foreground),
        ],
      ),
    );
  }
}
