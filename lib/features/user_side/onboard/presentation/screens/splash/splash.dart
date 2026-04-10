import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/features/app_start/presentation/cubit/app_start_cubit.dart';
import 'package:mint_talk/features/app_start/presentation/cubit/app_start_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AppStartCubit>()..checkAuthStatus(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppStartCubit, AppStartState>(
      listener: (context, state) {
        if (state is AppStartUnauthenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.phoneNumber);
        } else if (state is AppStartNeedsProfile) {
          // Send to profile setup
          Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
        } else if (state is AppStartAuthenticated) {
          // Send to home or main navigation
          Navigator.pushReplacementNamed(context, AppRoutes.mainNavigation);
        } else if (state is AppStartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          // Fallback to unauthenticated screen
          Navigator.pushReplacementNamed(context, AppRoutes.phoneNumber);
        }
      },
      child: const Scaffold(
        body: SplashInitialView(),
      ),
    );
  }
}

class SplashInitialView extends StatelessWidget {
  const SplashInitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
            image: const AssetImage(AppAssets.logo),
            fit: BoxFit.cover,
            height: 100.h,
            width: 100.w,
          ),
          SizedBox(height: 20.h),
          BlocBuilder<AppStartCubit, AppStartState>(
            builder: (context, state) {
              if (state is AppStartLoading) {
                return const CircularProgressIndicator.adaptive();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

