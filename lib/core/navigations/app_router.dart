import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/route_config.dart';
import 'package:mint_talk/core/transitions/routes/morphing_page_route.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/otp_verification/presentation/screen/otp_verification.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/country_selector_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/phone_form_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/screen/phone_number.dart';
import 'package:mint_talk/features/auth/presentation/screens/success/presentation/screen/success_screen.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/screen/host_profile_setup.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/screen/call_screen.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/screen/profile_screen.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';
import 'package:mint_talk/features/user_side/host_profile_screen/presentation/screen/host_profile_screen.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/screen/main_navigation_screen.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/privacy_policy/privacy_policy.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/splash/splash.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/screens/welcome/welcome.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/screens/audio_call.dart';
import 'package:mint_talk/features/user_side/online_users/presentation/screens/video_call.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/screen/profile_setup.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/success_setup_screen.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/screen/plan_detail_screen.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/screen/recharge_plans.dart';
import 'package:mint_talk/features/user_side/settings/presentation/screen/settings_screen.dart';

import 'package:mint_talk/features/wallet/presentation/pages/recharge_success_screen.dart';

class AppRouter {
  // ── Route definitions ──────────────────────────────────────────────
  static final Map<String, RouteConfig> _routes = {
    // ... other routes ...
    AppRoutes.rechargeSuccess: RouteConfig(
      builder: (settings) {
        final args = settings.arguments as Map<String, dynamic>;
        return RechargeSuccessScreen(
          addedPoints: args['addedPoints'] as int,
          totalBalance: args['totalBalance'] as int,
        );
      },
    ),
    // ...
    // host profile setup
    AppRoutes.hostProfileSetupScreen: RouteConfig(
      builder: (_) => const HostProfileSetupScreen(),
    ),

    // Onboarding
    AppRoutes.splash: RouteConfig(builder: (_) => const SplashScreen()),
    AppRoutes.welcome: RouteConfig(
      builder: (_) => const WelcomeScreen(),
      useMorphing: true,
    ),
    AppRoutes.privacyPolicy: RouteConfig(
      builder: (_) => const PrivacyPolicyScreen(),
    ),

    // Auth
    AppRoutes.phoneNumber: RouteConfig(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => getIt<CountrySelectorCubit>()),
          BlocProvider(create: (_) => getIt<PhoneFormCubit>()),
        ],
        child: const PhoneScreen(),
      ),
      useMorphing: true,
    ),
    AppRoutes.otpVerification: RouteConfig(
      builder: (_) => BlocProvider(
        create: (_) => getIt<OtpVerificationCubit>()..initialize(),
        child: const OtpVerificationScreen(),
      ),
      useMorphing: true,
    ),
    AppRoutes.success: RouteConfig(
      builder: (_) => const SuccessScreen(),
      useMorphing: true,
    ),

    // Profile setup
    AppRoutes.setupProfile: RouteConfig(
      builder: (_) => const ProfileSetupScreen(),
    ),
    AppRoutes.successSetup: RouteConfig(
      builder: (_) => const SuccessSetupScreen(),
    ),

    // Main app
    AppRoutes.mainNavigation: RouteConfig(
      builder: (_) => const MainNavigationScreen(),
    ),
    AppRoutes.profileScreen: RouteConfig(builder: (_) => const ProfileScreen()),
    AppRoutes.settingsScreen: RouteConfig(
      builder: (_) => const SettingsScreen(),
    ),

    // recharge plans
    AppRoutes.rechargePlansScreen: RouteConfig(
      builder: (_) => const RechargePlans(),
    ),
    AppRoutes.planDetail: RouteConfig(
      builder: (settings) {
        final args = RouteArgs.require<PlanDetailArgs>(settings);
        return PlanDetailScreen(args: args);
      },
    ),

    //video call online screen
    AppRoutes.videocallOnlineScreen: RouteConfig(
      builder: (_) => const VideoCallOnlineScreen(),
    ),

    //audio call online screen
    AppRoutes.audioCallOnlineScreen: RouteConfig(
      builder: (_) => const AudioCallOnlineScreen(),
    ),

    AppRoutes.hostProfileScreen: RouteConfig(
      builder: (settings) {
        final user = RouteArgs.require<HomeUserEntity>(settings);
        return HostProfileScreen(user: user);
      },
    ),
    AppRoutes.callScreen: RouteConfig(
      builder: (_) => BlocProvider(
        create: (_) => getIt<CallScreenCubit>(),
        child: const CallScreen(),
      ),
    ),
  };

  // ── Route generator ────────────────────────────────────────────────
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final config = _routes[settings.name];

    if (config == null) return _unknownRoute(settings);

    // Route guard — redirect if the guard callback returns false
    if (config.guard != null && !config.guard!()) {
      final redirect = config.guardRedirect ?? AppRoutes.splash;
      return onGenerateRoute(RouteSettings(name: redirect));
    }

    final child = config.builder(settings);

    if (config.useMorphing) {
      return MorphingPageRoute(settings: settings, child: child);
    }

    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }

  // ── Fallback ───────────────────────────────────────────────────────
  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
