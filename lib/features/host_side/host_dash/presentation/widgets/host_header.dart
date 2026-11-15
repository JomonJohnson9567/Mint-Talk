import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/rate_formatter.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_state.dart';

class HostHeader extends StatelessWidget {
  const HostHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.cw, 8.cw, 14.cw, 4.cw),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                AppAssets.mintTalkWordmark,
                height: 30.cw,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(width: 8.cw),
          // Host default earning rates (₹ per hostBillingUnit) from system config.
          BlocSelector<
            SystemConfigCubit,
            SystemConfigState,
            ({double? audioRate, double? videoRate, String unit})
          >(
            selector: (state) => (
              audioRate: state.hostAudioEarningRateInr,
              videoRate: state.hostVideoEarningRateInr,
              unit: state.hostBillingUnit,
            ),
            builder: (context, rates) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RateChip(
                    icon: Icons.call_rounded,
                    label: AppTexts.audioLabel,
                    value: rates.audioRate,
                    billingUnit: rates.unit,
                    accent: AppColors.audioAccent,
                    iconBackground: AppColors.audioBtnBg,
                  ),
                  SizedBox(width: 6.cw),
                  _RateChip(
                    icon: Icons.videocam_rounded,
                    label: AppTexts.videoLabel,
                    value: rates.videoRate,
                    billingUnit: rates.unit,
                    accent: AppColors.hostVideoAccent,
                    iconBackground: AppColors.hostVideoIconBg,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Call rate chip, formatted like the profile's call rate tiles; tapping it
/// opens the host analytics screen.
class _RateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double? value;
  final String billingUnit;
  final Color accent;
  final Color iconBackground;

  const _RateChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.billingUnit,
    required this.accent,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          getIt<NavigationService>().navigateTo(AppRoutes.hostAnalytics),
      child: Container(
        padding: EdgeInsets.fromLTRB(6.cw, 6.cw, 10.cw, 6.cw),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.profileDivider, width: 1.cw),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30.cw,
              height: 30.cw,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: accent, size: 17.csp),
            ),
            SizedBox(width: 7.cw),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.5.csp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.hostSubtitle,
                    height: 1.1,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value == null ? '—' : RateFormatter.inr(value, billingUnit),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 13.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
