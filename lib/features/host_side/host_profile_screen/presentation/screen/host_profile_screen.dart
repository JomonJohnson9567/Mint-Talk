import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_state.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_action_buttons.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_header.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_info_section.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_skeleton.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/widgets/host_profile_stats_row.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_cubit.dart';
import 'package:mint_talk/features/user_side/settings/presentation/cubit/logout/logout_state.dart';

class HostProfileScreen extends StatelessWidget {
  const HostProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LogoutCubit>(
      create: (_) => getIt<LogoutCubit>(),
      child: BlocConsumer<LogoutCubit, LogoutState>(
        listener: _onLogoutStateChanged,
        builder: (context, logoutState) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: AppColors.homeBackground,
                body: SafeArea(
                  bottom: false,
                  child: BlocBuilder<HostProfileCubit, HostProfileState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const HostProfileSkeleton();
                      }
                      if (state.status == HostProfileStatus.failure) {
                        return _ProfileLoadFailure(
                          message:
                              state.errorMessage ??
                              AppTexts.hostProfileLoadFailed,
                        );
                      }
                      return _HostProfileBody(profile: state);
                    },
                  ),
                ),
              ),
              if (logoutState.status == LogoutStatus.loading)
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
        padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
        child: _MaxWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BackTitleHeader(
                title: AppTexts.myProfile,
                subtitle: AppTexts.hostMyProfileSubtitle,
              ),
              SizedBox(height: 18.cw),
              HostProfileHeader(
                profile: profile,
                onEdit: () => _openEditProfile(context),
              ),
              SizedBox(height: 22.cw),
              const _SectionTitle(AppTexts.callRates),
              SizedBox(height: 10.cw),
              const HostProfileStatsRow(),
              SizedBox(height: 22.cw),
              const _SectionTitle(AppTexts.accountDetails),
              SizedBox(height: 10.cw),
              HostProfileInfoSection(profile: profile),
              SizedBox(height: 18.cw),
              const HostProfileActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final wasUpdated = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.hostProfileEditScreen);
    if (wasUpdated == true && context.mounted) {
      await context.read<HostProfileCubit>().loadProfile();
    }
  }
}

/// Nunito heading shown above each section.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.cw),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 18.csp,
          fontWeight: FontWeight.w800,
          color: AppColors.plumDeep,
        ),
      ),
    );
  }
}

class _ProfileLoadFailure extends StatelessWidget {
  final String message;

  const _ProfileLoadFailure({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
      child: _MaxWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BackTitleHeader(
              title: AppTexts.myProfile,
              subtitle: AppTexts.hostMyProfileSubtitle,
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56.cw,
                      height: 56.cw,
                      decoration: const BoxDecoration(
                        color: AppColors.hostVideoIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_off_outlined,
                        size: 26.csp,
                        color: AppColors.hostVideoAccent,
                      ),
                    ),
                    SizedBox(height: 14.cw),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.csp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    SizedBox(height: 14.cw),
                    OutlinedButton.icon(
                      onPressed: context.read<HostProfileCubit>().loadProfile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.plumDeep,
                        side: BorderSide(
                          color: AppColors.primaryColor,
                          width: 1.4.cw,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      icon: Icon(Icons.refresh_rounded, size: 18.csp),
                      label: Text(
                        AppTexts.retry,
                        style: TextStyle(
                          fontSize: 14.csp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Caps content width on tablets / landscape so cards don't stretch edge to
/// edge; a no-op on phones.
class _MaxWidth extends StatelessWidget {
  const _MaxWidth({required this.child});

  static const double maxWidth = 560;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
