import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_tile.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/contact_us_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_action_bottom_sheet.dart';

/// [SettingsContents] provides the main settings menu options, including
/// profile management, support, and authentication controls.
///
/// It uses [LogoutCubit] to handle the logout session flow.
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
          _buildContactUs(context),
          _buildTermsAndConditions(),
          _buildAboutUs(),
          _buildLogout(context, isLoading),
          _buildDeleteAccount(context),
        ],
      ),
    );
  }

  Widget _buildContactUs(BuildContext context) {
    return ProfileTile(
      icon: Icons.email,
      iconColor: AppColors.contactIcon,
      iconBackgroundColor: AppColors.contactIcon.withValues(alpha: 0.2),
      title: AppTexts.contactUs,
      onTap: () => ContactUsBottomSheetPresenter.show(context),
    );
  }

  Widget _buildTermsAndConditions() {
    return ProfileTile(
      icon: Icons.description,
      iconColor: AppColors.termsIcon,
      iconBackgroundColor: AppColors.termsIcon.withValues(alpha: 0.2),
      title: AppTexts.termsConditions,
      onTap: () {},
    );
  }

  Widget _buildAboutUs() {
    return ProfileTile(
      icon: Icons.info,
      iconColor: AppColors.aboutIcon,
      iconBackgroundColor: AppColors.aboutIcon.withValues(alpha: 0.2),
      title: AppTexts.aboutUs,
      onTap: () {},
    );
  }

  Widget _buildLogout(BuildContext context, bool isLoading) {
    return ProfileTile(
      icon: Icons.logout,
      iconColor: AppColors.favIcon,
      iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
      title: AppTexts.logout,
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
    return ProfileTile(
      icon: Icons.delete_forever_outlined,
      iconColor: AppColors.favIcon,
      iconBackgroundColor: AppColors.favIcon.withValues(alpha: 0.2),
      title: AppTexts.deleteAccount,
      onTap: () => SettingsActionBottomSheetPresenter.showDeleteAccount(
        context,
        onConfirm: () {
          // TODO: Implement delete account functionality
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
