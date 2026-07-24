import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class HostStaticContentScreen extends StatelessWidget {
  final String title;
  final String heroTitle;
  final String heroSubtitle;
  final IconData heroIcon;
  final Color heroColor;
  final List<HostStaticContentSection> sections;
  final String? footerNote;

  const HostStaticContentScreen({
    super.key,
    required this.title,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroIcon,
    required this.heroColor,
    required this.sections,
    this.footerNote,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(title: title, automaticallyImplyLeading: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HostStaticHeroCard(
                title: heroTitle,
                subtitle: heroSubtitle,
                icon: heroIcon,
                color: heroColor,
              ),
              SizedBox(height: 18.h),
              ...sections.map(
                (section) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _HostStaticSectionCard(section: section),
                ),
              ),
              if (footerNote != null) ...[
                SizedBox(height: 4.h),
                _HostStaticFooterNote(note: footerNote!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class HostStaticContentSection {
  final String title;
  final String content;

  const HostStaticContentSection({required this.title, required this.content});
}

class _HostStaticHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _HostStaticHeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.subtitleText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostStaticSectionCard extends StatelessWidget {
  final HostStaticContentSection section;

  const _HostStaticSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            section.content,
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              height: 1.7,
              color: AppColors.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _HostStaticFooterNote extends StatelessWidget {
  final String note;

  const _HostStaticFooterNote({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColors.onlineIndicator.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20.sp,
            color: AppColors.onlineIndicator,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              note,
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                height: 1.5,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
