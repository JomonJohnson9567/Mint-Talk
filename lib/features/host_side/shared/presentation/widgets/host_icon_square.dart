import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// The two icon tints the host side alternates between.
enum HostIconTint {
  lavender(AppColors.hostVideoIconBg, AppColors.hostVideoAccent),
  peach(AppColors.audioBtnBg, AppColors.audioAccent);

  final Color background;
  final Color foreground;

  const HostIconTint(this.background, this.foreground);

  /// Alternates lavender / peach down a list.
  static HostIconTint alternating(int index) => index.isEven ? lavender : peach;
}

/// Rounded-square icon badge used by the host settings rows, ledger stat
/// tiles and leave form fields.
class HostIconSquare extends StatelessWidget {
  final IconData icon;
  final HostIconTint tint;
  final double size;

  const HostIconSquare({
    super.key,
    required this.icon,
    this.tint = HostIconTint.lavender,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.cw,
      height: size.cw,
      decoration: BoxDecoration(
        color: tint.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: tint.foreground, size: (size * 0.5).csp),
    );
  }
}
