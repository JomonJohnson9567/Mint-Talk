import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Read-only phone / date of birth / gender rows. These are locked after
/// registration, so they're shown as info rows rather than disabled fields.
class UserProfileEditAccountCard extends StatelessWidget {
  const UserProfileEditAccountCard({
    super.key,
    required this.phone,
    required this.dob,
    required this.gender,
    this.dobError,
  });

  final String phone;
  final String dob;
  final String gender;
  final String? dobError;

  @override
  Widget build(BuildContext context) {
    final isFemale = gender.toLowerCase() == 'female';
    final rows = [
      _LockedRow(
        icon: Icons.phone_rounded,
        label: AppTexts.phoneNumberLabel,
        value: phone,
      ),
      _LockedRow(
        icon: Icons.cake_outlined,
        label: AppTexts.dateOfBirthText,
        value: dob,
        errorText: dobError,
      ),
      _LockedRow(
        icon: isFemale ? Icons.female_rounded : Icons.male_rounded,
        label: AppTexts.genderLabel,
        value: gender.isEmpty
            ? ''
            : '${gender[0].toUpperCase()}${gender.substring(1)}',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                rows[i],
                if (i != rows.length - 1)
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
        SizedBox(height: 10.cw),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded, size: 13.csp, color: AppColors.plumHint),
            SizedBox(width: 4.cw),
            Flexible(
              child: Text(
                AppTexts.lockedFieldsNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.csp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plumHint,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({
    required this.icon,
    required this.label,
    required this.value,
    this.errorText,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 11.cw),
      child: Row(
        children: [
          Container(
            width: 36.cw,
            height: 36.cw,
            decoration: const BoxDecoration(
              color: AppColors.popularCardBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19.csp, color: AppColors.primaryColor),
          ),
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
                    color: AppColors.plumMuted,
                  ),
                ),
                SizedBox(height: 2.cw),
                Text(
                  value.isEmpty ? '—' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.csp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.plumDeep,
                  ),
                ),
                if (errorText != null) ...[
                  SizedBox(height: 2.cw),
                  Text(
                    errorText!,
                    style: TextStyle(
                      fontSize: 12.csp,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.cw),
          Icon(Icons.lock_rounded, size: 16.csp, color: AppColors.plumHint),
        ],
      ),
    );
  }
}
