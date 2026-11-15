import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/widgets/host_settings_body.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';

class HostSettings extends StatelessWidget {
  const HostSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogoutCubit>(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: _onLogoutStateChanged,
        builder: (context, state) {
          return Stack(
            children: [
              const Scaffold(
                backgroundColor: AppColors.homeBackground,
                appBar: CustomAppBar(
                  title: AppTexts.settings,
                  automaticallyImplyLeading: false,
                  foregroundColor: AppColors.plumDeep,
                ),
                body: HostSettingsBody(),
              ),
              if (state.status == LogoutStatus.loading)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.18),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Same handling as the host profile screen's logout button.
  void _onLogoutStateChanged(BuildContext context, LogoutState state) {
    if (state.status == LogoutStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? 'Failed to logout'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state.status == LogoutStatus.success) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.phoneNumber, (route) => false);
    }
  }
}
