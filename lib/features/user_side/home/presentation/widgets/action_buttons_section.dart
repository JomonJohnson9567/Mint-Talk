import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/rate_formatter.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';
import 'package:mint_talk/core/constants/app_texts.dart';

class ActionButtonsSection extends StatelessWidget {
  const ActionButtonsSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Default rates come from system config (fetched on app load and again on
    // home pull-to-refresh) and are already in billingUnit, so they're shown
    // without conversion.
    final config = context.watch<SystemConfigCubit>().state;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
      child: Row(
        children: [
          Expanded(
            child: _CallCard(
              icon: Icons.videocam_rounded,
              title: AppTexts.videoCall,
              subtitle: _rateLabel(config.defaultVideoRate, config.billingUnit),
              background: AppColors.videoCardBg,
              accent: AppColors.primaryColor,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.videocallOnlineScreen),
            ),
          ),
          SizedBox(width: 10.cw),
          Expanded(
            child: _CallCard(
              icon: Icons.call_rounded,
              title: AppTexts.audioCall,
              subtitle: _rateLabel(config.defaultAudioRate, config.billingUnit),
              background: AppColors.audioCardBg,
              accent: AppColors.audioAccent,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.audioCallOnlineScreen),
            ),
          ),
        ],
      ),
    );
  }

  String _rateLabel(int? rate, String billingUnit) =>
      RateFormatter.raw(rate, billingUnit, unit: 'coins');
}

class _CallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color accent;
  final VoidCallback onTap;

  const _CallCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.cw),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42.cw,
              height: 42.cw,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.white, size: 20.csp),
            ),
            SizedBox(height: 6.cw),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 2.cw),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11.csp, color: AppColors.plumMuted),
            ),
          ],
        ),
      ),
    );
  }
}
