import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_action_buttons.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_header.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_info_section.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_stats_row.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';

class HostProfileScreen extends StatelessWidget {
  const HostProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogoutCubit>(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocListener<LogoutCubit, LogoutState>(
        listener: _onLogoutStateChanged,
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: const CustomAppBar(
            title: 'My Profile',
            automaticallyImplyLeading: true,
          ),
          body: BlocBuilder<HostProfileCubit, HostProfileState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              if (state.status == HostProfileStatus.failure) {
                return _ProfileLoadFailure(
                  message: state.errorMessage ?? 'Unable to load your profile.',
                );
              }
              return _HostProfileBody(profile: state);
            },
          ),
        ),
      ),
    );
  }

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
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.phoneNumber,
        (route) => false,
      );
    }
  }
}

class _HostProfileBody extends StatelessWidget {
  final HostProfileState profile;

  const _HostProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: context.read<HostProfileCubit>().loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),
            HostProfileHeader(profile: profile),
            SizedBox(height: 32.h),
            HostProfileStatsRow(profile: profile),
            SizedBox(height: 16.h),
            HostProfileInfoSection(
              profile: profile,
              onEdit: () => _openEditProfile(context),
            ),
            SizedBox(height: 24.h),
            const HostProfileActionButtons(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final wasUpdated = await Navigator.of(
      context,
    ).pushNamed<bool>(AppRoutes.hostProfileEditScreen);
    if (wasUpdated == true && context.mounted) {
      await context.read<HostProfileCubit>().loadProfile();
    }
  }
}

class _ProfileLoadFailure extends StatelessWidget {
  final String message;

  const _ProfileLoadFailure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: context.read<HostProfileCubit>().loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
