import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/welcome/welcome_cubit.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/widgets/welcome_contents.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tealBackground,
      body: BlocProvider(
        create: (context) => WelcomeCubit(),
        child: const WelcomeContents(),
      ),
    );
  }
}
