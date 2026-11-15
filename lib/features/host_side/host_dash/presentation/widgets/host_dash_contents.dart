import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/cubit/snack_bar_state.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';
import 'host_dash_motion.dart';
import 'host_greeting_banner.dart';
import 'host_header.dart';
import 'host_online_header.dart';
import 'host_welcome_card.dart';
import 'select_call_card.dart';
import 'hosts_online_grid.dart';
import 'promo_banner.dart';
import 'refer_host_banner.dart';

import 'host_dash_skeleton.dart';

class HostDashContents extends StatelessWidget {
  const HostDashContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HostDashCubit, HostDashState>(
      listenWhen: (previous, current) =>
          previous.preferenceUpdateStatus != current.preferenceUpdateStatus ||
          (current.notificationsBlocked && !previous.notificationsBlocked),
      listener: (context, state) {
        if (state.preferenceUpdateStatus ==
                HostPreferenceUpdateStatus.failure &&
            state.errorMessage != null) {
          showTopSnackBar(
            context,
            state.errorMessage!,
            type: SnackBarType.error,
          );
        } else if (state.notificationsBlocked &&
            state.preferenceUpdateStatus ==
                HostPreferenceUpdateStatus.success) {
          showTopSnackBar(
            context,
            AppTexts.hostNotificationsBlockedHint,
            type: SnackBarType.warning,
          );
        }
      },
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state.status == HostDashStatus.loading ||
            state.status == HostDashStatus.initial) {
          return const HostDashSkeleton();
        }

        final hostDashCubit = context.read<HostDashCubit>();
        final isOnline = state.callFlowMode != HostDashCallFlowMode.selecting;

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primaryColor,
            // Also re-fetches system config so the header's ₹/min earning
            // rates pick up admin changes.
            onRefresh: () => Future.wait([
              hostDashCubit.refreshDashboardData(),
              context.read<SystemConfigCubit>().fetchConfig(),
            ]),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(bottom: 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Once the host is online (waiting / incoming call) the
                    // header slims down and the profile + greeting collapse.
                    HostDashSwitcher(
                      child: isOnline
                          ? const HostOnlineHeader(key: ValueKey('online'))
                          : const HostHeader(key: ValueKey('idle')),
                    ),
                    HostDashCollapsible(
                      visible: !isOnline,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BlocBuilder<HostProfileCubit, HostProfileState>(
                            buildWhen: (previous, current) =>
                                previous.fullName != current.fullName ||
                                previous.imagePath != current.imagePath ||
                                previous.status != current.status,
                            builder: (context, profileState) {
                              return HostWelcomeCard(profile: profileState);
                            },
                          ),
                          const HostGreetingBanner(),
                        ],
                      ),
                    ),
                    SelectCallCard(
                      callFlowMode: state.callFlowMode,
                      isAudioSelected: state.isAudioSelected,
                      isVideoSelected: state.isVideoSelected,
                      isAnyCallSelected: state.isAnyCallSelected,
                      isStartingCall: state.isStartingCall,
                      isSocketConnected: state.isSocketConnected,
                      selectedCallLabel: state.selectedCallLabel,
                      onAudioToggle: hostDashCubit.toggleAudioCall,
                      onVideoToggle: hostDashCubit.toggleVideoCall,
                      onReadyTapped: hostDashCubit.startReceivingCalls,
                      onPickupTapped: hostDashCubit.pickupIncomingCall,
                      onDeclineTapped: hostDashCubit.declineIncomingCall,
                      onStopWaitingTapped: hostDashCubit.stopWaitingForCalls,
                      onReconnectTapped: hostDashCubit.retryConnection,
                    ),
                    HostsOnlineGrid(stacked: isOnline),
                    PromoBanner(
                      variant: isOnline
                          ? PromoBannerVariant.waiting
                          : PromoBannerVariant.earn,
                    ),
                    const ReferHostBanner(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
