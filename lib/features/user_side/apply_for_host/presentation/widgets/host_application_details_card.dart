import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../../domain/entities/host_application_status_entity.dart';

class HostApplicationDetailsCard extends StatelessWidget {
  final HostApplicationStatusEntity application;

  const HostApplicationDetailsCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application details',
            style: GoogleFonts.manrope(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 18.h),
          _DetailRow(label: 'Application ID', value: _shortId(application.id)),
          if (application.kyc != null) ...[
            Divider(height: 28.h, color: AppColors.borderSoft),
            _DetailRow(
              label: 'Document',
              value: _titleCase(application.kyc!.documentType),
            ),
            SizedBox(height: 14.h),
            _DetailRow(
              label: 'Document number',
              value: _maskDocument(application.kyc!.documentNumber),
            ),
            SizedBox(height: 14.h),
            _DetailRow(
              label: 'KYC status',
              value: _titleCase(application.kyc!.status),
              highlighted: true,
            ),
          ],
        ],
      ),
    );
  }

  String _shortId(String id) => id.length > 12 ? '${id.substring(0, 12)}…' : id;

  String _titleCase(String value) => value.isEmpty
      ? 'Not available'
      : '${value[0].toUpperCase()}${value.substring(1)}';

  String _maskDocument(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return '••••';
    return '•••• •••• ${digits.substring(digits.length - 4)}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlighted;

  const _DetailRow({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            color: AppColors.subtitleText,
          ),
        ),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: highlighted ? AppColors.primaryColor : AppColors.black,
          ),
        ),
      ),
    ],
  );
}
