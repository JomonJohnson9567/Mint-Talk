import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Plum section label above a leave form field.
class LeaveFieldLabel extends StatelessWidget {
  final String text;

  const LeaveFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.cw),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15.5.csp,
          fontWeight: FontWeight.w700,
          color: AppColors.plumDeep,
        ),
      ),
    );
  }
}

/// White, lavender-outlined box shared by the leave form fields.
class LeaveFieldBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const LeaveFieldBox({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);

    return Material(
      color: AppColors.cardWhite,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          padding: padding ?? EdgeInsets.all(12.cw),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.lavenderBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}
