import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_targets/domain/entities/host_target_entity.dart';
import 'target_progress_card.dart';

class HostTargetsSection extends StatelessWidget {
  final List<HostTargetEntity> targets;

  const HostTargetsSection({super.key, required this.targets});

  @override
  Widget build(BuildContext context) {
    if (targets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.flag_rounded, color: AppColors.primaryColor, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'My Targets',
              style: GoogleFonts.manrope(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...targets.map(
          (target) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: TargetProgressCard(target: target),
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
