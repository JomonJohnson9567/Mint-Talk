import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/success/presentation/cubit/success_animation_cubit.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/success/presentation/widgets/starting_point.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SuccessAnimationCubit(),
      child: Scaffold(
        backgroundColor: AppColors.tealBackground,
        body: const ScreenStartPoint(),
      ),
    );
  }
}
