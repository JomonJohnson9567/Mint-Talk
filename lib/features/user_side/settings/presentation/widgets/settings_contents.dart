import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_menu_card.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/contact_us_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_action_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_page_header.dart';

class SettingsContents extends StatelessWidget {
  const SettingsContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: _onLogoutStateChanged,
        builder: (context, state) {
          final isLoading = state.status == LogoutStatus.loading;

          return Stack(
            children: [
              _buildSettingsList(context, isLoading),
              if (isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  /// Handles state changes from [LogoutCubit].
  void _onLogoutStateChanged(BuildContext context, LogoutState state) {
    if (state.status == LogoutStatus.failure) {
      _showErrorSnackBar(context, state.errorMessage ?? 'Failed to logout');
    } else if (state.status == LogoutStatus.success) {
      _navigateToLogin(context);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.phoneNumber,
      (route) => false,
    );
  }

  Widget _buildSettingsList(BuildContext context, bool isLoading) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SettingsPageHeader(),
          SizedBox(height: 20.cw),
          ProfileMenuCard(
            items: [
              ProfileMenuItem(
                icon: Icons.support_agent_rounded,
                label: AppTexts.contactUs,
                onTap: () => ContactUsBottomSheetPresenter.show(context),
              ),
              ProfileMenuItem(
                icon: Icons.description_rounded,
                label: AppTexts.termsConditions,
                onTap: () {},
              ),
              ProfileMenuItem(
                icon: Icons.info_rounded,
                label: AppTexts.aboutUs,
                onTap: () {},
              ),
            ],
          ),
          SizedBox(height: 12.cw),
          _buildLogout(context, isLoading),
          SizedBox(height: 12.cw),
          _buildDeleteAccount(context),
        ],
      ),
    );
  }

  Widget _buildLogout(BuildContext context, bool isLoading) {
    return ProfileActionRow(
      icon: Icons.logout_rounded,
      label: AppTexts.logOut,
      isLoading: isLoading,
      onTap: () {
        if (isLoading) return;
        SettingsActionBottomSheetPresenter.showLogout(
          context,
          onConfirm: () => context.read<LogoutCubit>().logout(),
        );
      },
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return ProfileActionRow(
      icon: Icons.delete_forever_rounded,
      label: AppTexts.deleteAccountRow,
      iconColor: AppColors.linkMagenta,
      labelColor: AppColors.linkMagenta,
      backgroundColor: AppColors.linkMagenta.withValues(alpha: 0.08),
      onTap: () => SettingsActionBottomSheetPresenter.showDeleteAccount(
        context,
        onConfirm: () {
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.18),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
