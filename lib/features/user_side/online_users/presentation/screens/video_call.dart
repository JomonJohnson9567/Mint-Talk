import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_state.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/home_header.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/host_list_listeners.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_grid.dart';
import 'package:mint_talk/features/user_side/home/presentation/widgets/user_status_tabs.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/available_section_title.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/host_layout_toggle.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/host_search_field.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/widgets/video_call_banner.dart';

class VideoCallOnlineScreen extends StatelessWidget {
  const VideoCallOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      appBar: CustomAppBar(
        title: AppTexts.videoCalls,
        foregroundColor: AppColors.plumDeep,
        actions: [
          const CoinBalancePill(iconAsset: AppAssets.rechargeCoin),
          SizedBox(width: 14.cw),
        ],
      ),
      body: BlocProvider(
        create: (context) => getIt<HomeCubit>(),
        child: HostListListeners(
          child: SafeArea(
            bottom: false,
            child: UserGrid(
              callType: CallType.video,
              header: const Column(
                children: [
                  VideoCallBanner(),
                  HostSearchField(),
                  UserStatusTabs(
                    tabs: [
                      (HomeTab.active, AppTexts.onlineNow),
                      (HomeTab.all, AppTexts.allHosts),
                    ],
                  ),
                ],
              ),
              sectionTitleBuilder: (tab) => AvailableSectionTitle(
                tab: tab,
                callType: CallType.video,
                trailing: const HostLayoutToggle(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
