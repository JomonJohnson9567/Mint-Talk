import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/splash/splash_cubit.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SplashCubit(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (previous, current) =>
          !previous.shouldNavigate && current.shouldNavigate,
      listener: (context, state) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage(AppAssets.logo),
                fit: BoxFit.cover,
                height: 100.h,
                width: 100.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
