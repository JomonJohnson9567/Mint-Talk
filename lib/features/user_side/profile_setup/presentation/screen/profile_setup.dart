import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/setup_contents.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_state.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ProfileCubit>()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.creamBackground,
          body: DecoratedBox(
            // Same soft surface as the OTP screen so the flow reads as one.
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.creamBackground, AppColors.cardWhite],
                stops: [0.3, 0.6],
              ),
            ),
            child: SafeArea(
              child: BlocListener<ProfileCubit, ProfileState>(
                listenWhen: (previous, current) =>
                    previous.submissionStatus != current.submissionStatus,
                listener: (context, state) {
                  if (state.submissionStatus ==
                      ProfileSubmissionStatus.success) {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.successSetup,
                    );
                  } else if (state.submissionStatus ==
                      ProfileSubmissionStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.plumDeep,
                        content: Text(
                          state.errorMessage ?? 'Submission failed',
                        ),
                      ),
                    );
                  }
                },
                child: const SetupContents(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
