import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/rate_formatter.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_state.dart';
import 'package:mint_talk/features/host_side/shared/presentation/widgets/host_icon_square.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';

/// Side-by-side video (lavender) and audio (peach) rate tiles, each with a
/// chip showing whether the host is live for that call type right now.
class HostProfileStatsRow extends StatelessWidget {
  const HostProfileStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Host default earning rates (₹ per hostBillingUnit) from system config.
    final config = context.watch<SystemConfigCubit>().state;
    // Live only once the host has tapped Ready — while still picking
    // options the selection flags are just toggles, not availability.
    final (videoLive, audioLive) = context.select<HostDashCubit, (bool, bool)>((
      cubit,
    ) {
      final dash = cubit.state;
      final isLive = dash.callFlowMode != HostDashCallFlowMode.selecting;
      return (isLive && dash.isVideoSelected, isLive && dash.isAudioSelected);
    });

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _RateTile(
              icon: Icons.videocam_rounded,
              tint: HostIconTint.lavender,
              background: AppColors.hostVideoTileBg,
              label: AppTexts.videoRateLabel,
              value: _rate(
                config.hostVideoEarningRateInr,
                config.hostBillingUnit,
              ),
              isLive: videoLive,
            ),
          ),
          SizedBox(width: 10.cw),
          Expanded(
            child: _RateTile(
              icon: Icons.phone_rounded,
              tint: HostIconTint.peach,
              background: AppColors.hostAudioTileBg,
              label: AppTexts.audioRateLabel,
              value: _rate(
                config.hostAudioEarningRateInr,
                config.hostBillingUnit,
              ),
              isLive: audioLive,
            ),
          ),
        ],
      ),
    );
  }

  String _rate(double? value, String hostBillingUnit) =>
      value == null ? '—' : RateFormatter.inr(value, hostBillingUnit);
}

class _RateTile extends StatelessWidget {
  final IconData icon;
  final HostIconTint tint;
  final Color background;
  final String label;
  final String value;
  final bool isLive;

  const _RateTile({
    required this.icon,
    required this.tint,
    required this.background,
    required this.label,
    required this.value,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.cw),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18.cw),
        border: Border.all(color: AppColors.profileDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HostIconSquare(icon: icon, tint: tint, size: 40),
              SizedBox(width: 8.cw),
              // Shrinks rather than overflowing on narrow tiles / large text.
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _AvailabilityChip(isLive: isLive),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.cw),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.csp,
              fontWeight: FontWeight.w500,
              color: AppColors.hostSubtitle,
            ),
          ),
          SizedBox(height: 2.cw),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.nunito(
                fontSize: 20.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  final bool isLive;

  const _AvailabilityChip({required this.isLive});

  @override
  Widget build(BuildContext context) {
    final (label, color) = isLive
        ? (AppTexts.rateLive, AppColors.onlineIndicator)
        : (AppTexts.offline, AppColors.plumHint);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.cw, vertical: 4.cw),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10.cw),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.cw,
            height: 6.cw,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4.cw),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.csp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
