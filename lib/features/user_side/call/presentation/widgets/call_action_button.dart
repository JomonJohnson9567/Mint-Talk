import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final double buttonSize;
  final double iconSize;
  final String? label;
  final TextStyle? labelStyle;
  final List<BoxShadow>? boxShadow;

  /// Accessible name announced by screen readers, independent of [label] —
  /// this button may have no visible caption at all (e.g. the in-call
  /// controls) while still needing a name for accessibility.
  final String? semanticLabel;

  const CallActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.iconColor,
    required this.backgroundColor,
    this.buttonSize = 50,
    this.iconSize = 24,
    this.label,
    this.labelStyle,
    this.boxShadow,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: buttonSize.w,
      height: buttonSize.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: boxShadow,
      ),
      child: IconButton(
        tooltip: semanticLabel ?? label,
        onPressed: onTap,
        icon: Icon(icon, color: iconColor, size: iconSize.sp),
      ),
    );

    if (label == null) {
      return button;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        SizedBox(height: 8.h),
        Text(label!, style: labelStyle),
      ],
    );
  }
}
