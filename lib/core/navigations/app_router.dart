// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/screen/otp_verification.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/success/presentation/screen/success_screen.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/privacy_policy.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/splash/splash.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/welcome.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/screen/phone_number.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/country_selector_cubit.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/phone_form_cubit.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart';
import 'package:mint_talk/core/transitions/routes/morphing_page_route.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/screen/profile_setup.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Routes that use morphing transitions
    final morphingRoutes = [
      AppRoutes.welcome,
      AppRoutes.phoneNumber,
      AppRoutes.otpVerification,
      AppRoutes.success,
    ];

    final useMorphingTransition = morphingRoutes.contains(settings.name);

    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case AppRoutes.welcome:
        if (useMorphingTransition) {
          return _buildMorphingRoute(
            settings: settings,
            child: const WelcomeScreen(),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const WelcomeScreen(),
        );

      case AppRoutes.phoneNumber:
        final screen = MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => CountrySelectorCubit()),
            BlocProvider(create: (context) => PhoneFormCubit()),
          ],
          child: const PhoneScreen(),
        );
        if (useMorphingTransition) {
          return _buildMorphingRoute(settings: settings, child: screen);
        }
        return MaterialPageRoute(settings: settings, builder: (_) => screen);

      case AppRoutes.otpVerification:
        final screen = BlocProvider(
          create: (context) => OtpVerificationCubit(),
          child: const OtpVerificationScreen(),
        );
        if (useMorphingTransition) {
          return _buildMorphingRoute(settings: settings, child: screen);
        }
        return MaterialPageRoute(settings: settings, builder: (_) => screen);

      case AppRoutes.success:
        if (useMorphingTransition) {
          return _buildMorphingRoute(
            settings: settings,
            child: const SuccessScreen(),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SuccessScreen(),
        );

      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PrivacyPolicyScreen(),
        );

      case AppRoutes.setupProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileSetupScreen(),
        );
    }

    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }

  static Route<dynamic> _buildMorphingRoute({
    required RouteSettings settings,
    required Widget child,
  }) {
    return MorphingPageRoute(settings: settings, child: child);
  }
}
