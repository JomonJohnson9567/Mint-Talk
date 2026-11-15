import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/cubit/profile_info_cubit.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/widgets/profile_contents.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileInfoCubit>()..loadProfileInfo(),
      child: const Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: SafeArea(bottom: false, child: ProfileContents()),
      ),
    );
  }
}
