import 'package:flutter/material.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Plum-styled labelled text field for the host application form, matching
/// the Edit Profile fields. Kept local so the shared `ProfileField` used by
/// the setup flows stays untouched.
class ApplyFormField extends StatelessWidget {
  const ApplyFormField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.initialValue,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  /// When false the field is shown but cannot be focused or edited.
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.cw);
    OutlineInputBorder border(Color color, [double width = 1.5]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    final isMultiline = (maxLines ?? 1) > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.cw),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.csp,
              fontWeight: FontWeight.w700,
              color: AppColors.plumDeep,
            ),
          ),
        ),
        SizedBox(height: 8.cw),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          textInputAction: isMultiline
              ? TextInputAction.newline
              : TextInputAction.next,
          cursorColor: AppColors.primaryColor,
          style: TextStyle(
            fontSize: 15.csp,
            fontWeight: FontWeight.w600,
            color: AppColors.plumDeep,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14.csp,
              fontWeight: FontWeight.w400,
              color: AppColors.plumHint,
            ),
            errorText: errorText,
            errorStyle: TextStyle(fontSize: 12.csp, color: Colors.red.shade700),
            counterStyle: TextStyle(
              fontSize: 11.5.csp,
              fontWeight: FontWeight.w600,
              color: AppColors.plumHint,
            ),
            prefixIcon: isMultiline
                // Pin the icon to the first line instead of centring it
                // vertically in the taller bio box.
                ? Padding(
                    padding: EdgeInsets.only(bottom: 44.cw),
                    child: Icon(
                      prefixIcon,
                      size: 20.csp,
                      color: AppColors.primaryColor,
                    ),
                  )
                : Icon(prefixIcon, size: 20.csp, color: AppColors.primaryColor),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.cw,
              vertical: 15.cw,
            ),
            enabledBorder: border(AppColors.lavenderBorder),
            disabledBorder: border(AppColors.lavenderBorder),
            focusedBorder: border(AppColors.primaryColor),
            errorBorder: border(Colors.red.shade700),
            focusedErrorBorder: border(Colors.red.shade700),
          ),
        ),
      ],
    );
  }
}
