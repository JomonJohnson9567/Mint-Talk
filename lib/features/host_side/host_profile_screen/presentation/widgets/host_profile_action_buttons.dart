// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';
import 'package:mint_talk/features/user_side/settings/presentation/widgets/settings_action_bottom_sheet.dart';

class HostProfileActionButtons extends StatelessWidget {
  const HostProfileActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogoutCubit, LogoutState>(
      builder: (context, state) {
        final isLoading = state.status == LogoutStatus.loading;

        return Stack(
          children: [
            Column(
              children: [
                // Logout button
                PrimaryButton(
                  text: 'Logout',
                  onPressed: isLoading
                      ? null
                      : () => _showLogoutConfirmation(context),
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                ),
                SizedBox(height: 12.h),
                // Delete Account outlined button
                const _DeleteAccountButton(),
              ],
            ),
            if (isLoading) _LogoutLoadingOverlay(),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final logoutCubit = context.read<LogoutCubit>();
    SettingsActionBottomSheetPresenter.showLogout(
      context,
      onConfirm: () => logoutCubit.logout(),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red.withAlpha(120)),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        icon: Icon(Icons.delete_outline_rounded, size: 18.sp),
        label: Text(
          'Delete Account',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _LogoutLoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.white.withValues(alpha: 0.7),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      ),
    );
  }
}

