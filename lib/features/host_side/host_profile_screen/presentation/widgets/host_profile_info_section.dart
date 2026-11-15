import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/cubit/snack_bar_state.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';

/// Cream card listing the host's account details as read-only rows. The
/// referral code row copies the code so the host can share it.
class HostProfileInfoSection extends StatelessWidget {
  final HostProfileState profile;

  const HostProfileInfoSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final fields =
        <({IconData icon, String label, String value, bool copyable})>[
          (
            icon: Icons.person_outline_rounded,
            label: AppTexts.fullNameLabel,
            value: profile.displayName,
            copyable: false,
          ),
          (
            icon: Icons.phone_android_rounded,
            label: AppTexts.phoneNumberLabel,
            value: profile.displayPhone,
            copyable: false,
          ),

          (
            icon: Icons.cake_outlined,
            label: AppTexts.dateOfBirthText,
            value: profile.displayDob,
            copyable: false,
          ),
          (
            icon: Icons.wc_rounded,
            label: AppTexts.genderLabel,
            value: profile.displayGender,
            copyable: false,
          ),
          (
            icon: Icons.card_giftcard_rounded,
            label: AppTexts.hostReferralCodeLabel,
            value: profile.displayReferralCode,
            copyable: profile.hasReferralCode,
          ),
        ];

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            _InfoRow(
              icon: fields[i].icon,
              tint: HostIconTint.alternating(i),
              label: fields[i].label,
              value: fields[i].value,
              onCopy: fields[i].copyable
                  ? () => _copy(context, fields[i].value)
                  : null,
            ),
            if (i != fields.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 68.cw,
                endIndent: 14.cw,
                color: AppColors.profileDivider,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    showTopSnackBar(
      context,
      AppTexts.referralCodeCopied,
      type: SnackBarType.success,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final HostIconTint tint;
  final String label;
  final String value;

  /// When set, the row is tappable and shows a copy icon.
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 11.cw),
      child: Row(
        children: [
          HostIconSquare(icon: icon, tint: tint, size: 40),
          SizedBox(width: 14.cw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.csp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hostSubtitle,
                  ),
                ),
                SizedBox(height: 2.cw),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.csp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumDeep,
                    letterSpacing: onCopy != null ? 1.2 : null,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null) ...[
            SizedBox(width: 8.cw),
            Icon(
              Icons.copy_rounded,
              size: 18.csp,
              color: AppColors.primaryColor,
            ),
          ],
        ],
      ),
    );

    if (onCopy == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onCopy, child: row),
    );
  }
}
