import 'package:flutter/material.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/setup_contents.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_state.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/referral_cubit.dart';
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProfileCubit>()),
        BlocProvider(create: (context) => getIt<ReferralCubit>()),
      ],
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocListener<ProfileCubit, ProfileState>(
            listenWhen: (previous, current) =>
                previous.submissionStatus != current.submissionStatus,
            listener: (context, state) {
              if (state.submissionStatus == ProfileSubmissionStatus.success) {
                Navigator.pushReplacementNamed(context, AppRoutes.successSetup);
              } else if (state.submissionStatus == ProfileSubmissionStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'Submission failed')),
                );
              }
            },
            child: const SetupContents(),
          ),
        ),
      ),
    );
  }
}
