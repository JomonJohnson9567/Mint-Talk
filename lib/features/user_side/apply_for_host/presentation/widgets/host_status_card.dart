import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';

class HostStatusCard extends StatelessWidget {
  final String status;

  const HostStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final style = _StatusStyle.from(status);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [style.color.withAlpha(31), style.color.withAlpha(8)],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: style.color.withAlpha(70)),
      ),
      child: Column(
        children: [
          Container(
            width: 76.w,
            height: 76.w,
            decoration: BoxDecoration(
              color: style.color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.color, size: 42.sp),
          ),
          SizedBox(height: 18.h),
          Text(
            style.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: style.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            style.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  final Color color;
  final IconData icon;
  final String title;
  final String description;

  const _StatusStyle(this.color, this.icon, this.title, this.description);

  factory _StatusStyle.from(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const _StatusStyle(
          AppColors.onlineIndicator,
          Icons.verified_rounded,
          'Application Approved',
          'Congratulations! Your host application has been approved.',
        );
      case 'rejected':
        return const _StatusStyle(
          AppColors.red,
          Icons.cancel_rounded,
          'Application Rejected',
          'Your application was not approved. Review the details below.',
        );
      default:
        return const _StatusStyle(
          AppColors.termsIcon,
          Icons.hourglass_top_rounded,
          'Review in Progress',
          'Your application is with our team. We’ll notify you when the review is complete.',
        );
    }
  }
}
