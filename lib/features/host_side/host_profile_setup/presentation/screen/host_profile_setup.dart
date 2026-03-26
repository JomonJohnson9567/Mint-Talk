import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/widgets/host_setup_contents.dart';

class HostProfileSetupScreen extends StatelessWidget {
  const HostProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HostProfileSetupCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: const SafeArea(child: HostSetupContents()),
      ),
    );
  }
}
