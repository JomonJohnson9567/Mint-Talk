import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/settings_tile.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_action_bottom_sheet.dart';

/// Peach "Log out" tile (same as host settings) with a quieter
/// "Delete account" link under it. The logout spinner is shown by
/// [HostProfileScreen]'s overlay.
class HostProfileActionButtons extends StatelessWidget {
  const HostProfileActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsTile(
          icon: Icons.logout_rounded,
          title: AppTexts.logOut,
          isDestructive: true,
          onTap: () {
            final logoutCubit = context.read<LogoutCubit>();
            SettingsActionBottomSheetPresenter.showLogout(
              context,
              onConfirm: logoutCubit.logout,
            );
          },
        ),
        SizedBox(height: 6.cw),
        Center(
          child: TextButton.icon(
            onPressed: () =>
                SettingsActionBottomSheetPresenter.showDeleteAccount(
                  context,
                  // Account deletion isn't wired up yet — same as the user side.
                  onConfirm: () {},
                ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.linkMagenta,
              shape: const StadiumBorder(),
            ),
            icon: Icon(Icons.delete_outline_rounded, size: 18.csp),
            label: Text(
              AppTexts.deleteAccountRow,
              style: TextStyle(fontSize: 14.csp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
