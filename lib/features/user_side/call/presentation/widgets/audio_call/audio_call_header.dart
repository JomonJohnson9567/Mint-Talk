import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Call-type badge, caption ("Audio call" / "Video call") and the other
/// participant's name.
class AudioCallHeader extends StatelessWidget {
  final String name;
  final IconData icon;
  final String label;

  /// Glass badge and white text for the video screen, where the header sits
  /// over the camera feed.
  final bool onDark;

  const AudioCallHeader({
    super.key,
    required this.name,
    this.icon = Icons.call_rounded,
    this.label = AppTexts.audioCallLabel,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44.cw,
          height: 44.cw,
          decoration: BoxDecoration(
            color: onDark
                ? AppColors.white.withValues(alpha: 0.18)
                : AppColors.videoBtnBg,
            shape: BoxShape.circle,
            border: onDark
                ? Border.all(color: AppColors.white.withValues(alpha: 0.28))
                : null,
          ),
          child: Icon(
            icon,
            color: onDark ? AppColors.white : AppColors.primaryColor,
            size: 22.csp,
          ),
        ),
        SizedBox(height: 6.cw),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.csp,
            fontWeight: FontWeight.w500,
            color: onDark
                ? AppColors.white.withValues(alpha: 0.82)
                : AppColors.plumMuted,
          ),
        ),
        SizedBox(height: 2.cw),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.csp,
            fontWeight: FontWeight.w800,
            color: onDark ? AppColors.white : AppColors.plumDeep,
          ),
        ),
      ],
    );
  }
}
