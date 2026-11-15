import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final HostIconTint tint;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Peach card with a coral title — used for Log out.
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.tint = HostIconTint.lavender,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);
    final accent = isDestructive ? AppColors.audioAccent : AppColors.plumDeep;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.cw),
      child: Material(
        color: isDestructive ? AppColors.audioBtnBg : AppColors.cardWhite,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 12.cw),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: isDestructive
                  ? null
                  : Border.all(color: AppColors.profileDivider),
              boxShadow: isDestructive
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                HostIconSquare(
                  icon: icon,
                  tint: isDestructive ? HostIconTint.peach : tint,
                ),
                SizedBox(width: 14.cw),
                Expanded(
                  child: _SettingsTileInfo(
                    title: title,
                    subtitle: subtitle,
                    titleColor: accent,
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 24.csp, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsTileInfo extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color titleColor;

  const _SettingsTileInfo({
    required this.title,
    required this.subtitle,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.5.csp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2.cw),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 12.csp, color: AppColors.hostSubtitle),
          ),
        ],
      ],
    );
  }
}
