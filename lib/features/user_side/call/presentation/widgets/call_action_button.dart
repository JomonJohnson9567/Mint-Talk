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
