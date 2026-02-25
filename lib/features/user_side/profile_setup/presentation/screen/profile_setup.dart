import 'package:flutter/material.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/setup_contents.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_setup_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/profile_setup_state.dart';
 
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: BlocListener<ProfileSetupCubit, ProfileSetupState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, state) {
            if (state.status == ProfileSetupStatus.success) {
              Navigator.pushReplacementNamed(context, AppRoutes.successSetup);
            }
          },
          child: const SetupContents(),
        ),
      ),
    );
  }
}
