import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

class ProfileMenuItem {
  const ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primaryColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
}

/// White rounded card listing [items] separated by hairline dividers.
class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key, required this.items});

  final List<ProfileMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.cw);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: radius,
        border: Border.all(color: AppColors.profileDivider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              _ProfileMenuRow(
                icon: items[i].icon,
                iconColor: items[i].iconColor,
                label: items[i].label,
                onTap: items[i].onTap,
              ),
              if (i != items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 64.cw,
                  endIndent: 14.cw,
                  color: AppColors.profileDivider,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standalone pill row (e.g. "Log out") styled to sit below a
/// [ProfileMenuCard]. Shows a spinner in place of the chevron while
/// [isLoading].
class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primaryColor,
    this.labelColor = AppColors.plumDeep,
    this.backgroundColor = AppColors.videoCardBg,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;
  final Color backgroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18.cw),
      clipBehavior: Clip.antiAlias,
      child: _ProfileMenuRow(
        icon: icon,
        iconColor: iconColor,
        label: label,
        labelColor: labelColor,
        chipColor: AppColors.white.withValues(alpha: 0.7),
        isLoading: isLoading,
        onTap: onTap,
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor = AppColors.plumDeep,
    this.chipColor = AppColors.popularCardBg,
    this.isLoading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final Color labelColor;
  final Color chipColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 9.cw),
        child: Row(
          children: [
            Container(
              width: 36.cw,
              height: 36.cw,
              decoration: BoxDecoration(
                color: chipColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19.csp, color: iconColor),
            ),
            SizedBox(width: 14.cw),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.csp,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
            ),
            if (isLoading)
              SizedBox(
                width: 18.cw,
                height: 18.cw,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 24.csp,
                color: labelColor,
              ),
          ],
        ),
      ),
    );
  }
}
