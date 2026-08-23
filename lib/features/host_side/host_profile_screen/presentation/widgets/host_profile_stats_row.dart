// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/rate_formatter.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';

class HostProfileStatsRow extends StatelessWidget {
  final HostProfileState profile;

  const HostProfileStatsRow({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final billingUnit = context.watch<SystemConfigCubit>().state.billingUnit;
    final stats = [
      _StatItem(
        icon: Icons.phone_rounded,
        label: 'Audio rate',
        value: _rate(profile.audioRate, billingUnit),
        extra: _availability(profile.isAudioAllowed),
      ),
      _StatItem(
        icon: Icons.videocam_rounded,
        label: 'Video rate',
        value: _rate(profile.videoRate, billingUnit),
        extra: _availability(profile.isVideoAllowed),
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) => _StatCell(stat: stat)).toList(),
      ),
    );
  }

  String _rate(int? value, String billingUnit) =>
      value == null ? '—' : RateFormatter.label(value, billingUnit);

  String _availability(bool? value) {
    return switch (value) {
      true => 'Available',
      false => 'Unavailable',
      null => 'Not set',
    };
  }
}

class _StatCell extends StatelessWidget {
  final _StatItem stat;

  const _StatCell({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(stat.icon, color: AppColors.primaryColor, size: 22.sp),
        SizedBox(height: 6.h),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.subtitleText,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          stat.value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          stat.extra,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors.subtitleText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final String extra;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.extra,
  });
}
