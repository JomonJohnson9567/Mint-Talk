import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/transitions/cubit/snack_bar_state.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'host_header.dart';
import 'host_welcome_card.dart';
import 'select_call_card.dart';
import 'hosts_online_grid.dart';
import 'promo_banner.dart';

class HostDashContents extends StatelessWidget {
  const HostDashContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HostDashCubit, HostDashState>(
      listenWhen: (previous, current) =>
          previous.preferenceUpdateStatus != current.preferenceUpdateStatus,
      listener: (context, state) {
        if (state.preferenceUpdateStatus ==
                HostPreferenceUpdateStatus.failure &&
            state.errorMessage != null) {
          showTopSnackBar(
            context,
            state.errorMessage!,
            type: SnackBarType.error,
          );
        }
      },
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        final hostDashCubit = context.read<HostDashCubit>();

        return SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HostHeader(),
                  BlocBuilder<HostProfileCubit, HostProfileState>(
                    buildWhen: (previous, current) =>
                        previous.fullName != current.fullName ||
                        previous.imagePath != current.imagePath ||
                        previous.status != current.status,
                    builder: (context, profileState) {
                      return HostWelcomeCard(profile: profileState);
                    },
                  ),
                  SelectCallCard(
                    callFlowMode: state.callFlowMode,
                    isAudioSelected: state.isAudioSelected,
                    isVideoSelected: state.isVideoSelected,
                    isAnyCallSelected: state.isAnyCallSelected,
                    isStartingCall: state.isStartingCall,
                    selectedCallLabel: state.selectedCallLabel,
                    onAudioToggle: hostDashCubit.toggleAudioCall,
                    onVideoToggle: hostDashCubit.toggleVideoCall,
                    onReadyTapped: hostDashCubit.startReceivingCalls,
                    onPickupTapped: hostDashCubit.pickupIncomingCall,
                    onDeclineTapped: hostDashCubit.declineIncomingCall,
                    onStopWaitingTapped: hostDashCubit.stopWaitingForCalls,
                  ),
                  SizedBox(height: 10.h),
                  const HostsOnlineGrid(),
                  SizedBox(height: 20.h),
                  const PromoBanner(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
