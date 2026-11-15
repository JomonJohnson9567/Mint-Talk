import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/host_entity.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_profile_header.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_special_categories.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_warning_banner.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/widgets/host_action_buttons.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_cubit.dart';
import 'package:mint_talk/features/shared/block_users/presentation/cubit/blocked_users_state.dart';

class ScreenContents extends StatelessWidget {
  final HostEntity host;

  const ScreenContents({super.key, required this.host});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlockedUsersCubit, BlockedUsersState>(
      listener: (context, state) {
        if (state is BlockedUsersLoaded &&
            state.lastAction == BlockAction.blocked) {
          // The app-level messenger outlives this route, so the snackbar
          // stays up on the host list the user lands back on.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${host.fullName.isNotEmpty ? host.fullName : 'Host'} has been blocked',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else if (state is BlockedUsersLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is BlockedUsersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: BackTitleHeader(
                    title: AppTexts.profileDetails,
                    subtitle: AppTexts.hostProfileSubtitle,
                  ),
                ),
                SizedBox(
                  width: 68.cw,
                  height: 68.cw,
                  child: const HostProfileMascot(),
                ),
              ],
            ),
            SizedBox(height: 8.cw),
            HostProfileHeader(
              hostId: host.id,
              name: host.fullName,
              isOnline: host.presence?.isAvailableForCalls ?? false,
              isBusy: host.presence?.isOnCall ?? false,
              imageUrl: host.avatarUrl,
            ),
            SizedBox(height: 22.cw),
            HostActionButtons(host: host),
            SizedBox(height: 22.cw),
            const HostSpecialCategories(),
            SizedBox(height: 14.cw),
            const HostWarningBanner(),
          ],
        ),
      ),
    );
  }
}
