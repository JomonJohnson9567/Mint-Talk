import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_router.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/theme.dart';
import 'package:mint_talk/core/widgets/secure_app_overlay.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mint_talk/features/shared/system_config/presentation/cubit/system_config_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/floating_call_bubble.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<WalletCubit>()),
            BlocProvider(create: (context) => getIt<NotificationsCubit>()),
            // Fetched once here, on app load, independent of auth/role —
            // read from anywhere via context.watch<SystemConfigCubit>().
            BlocProvider(create: (context) => getIt<SystemConfigCubit>()..fetchConfig()),
            // Provided once here, app-wide, same as WalletCubit/NotificationsCubit
            // above — so an active call survives CallScreen being popped
            // (minimized to the floating bubble) instead of being torn down.
            BlocProvider(create: (context) => getIt<CallScreenCubit>()),
          ],
          child: MaterialApp(
            navigatorKey: getIt<NavigationService>().navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Mint Talk',
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            // App-wide, independent of whether CallScreen or the minimized
            // FloatingCallBubble is what's currently visible (or neither, if
            // the call ended while some other screen was on top) — the
            // server debits/credits points as part of ending the call, so
            // WalletCubit's balance is stale from that moment until this
            // re-fetches it.
            builder: (context, child) =>
                BlocListener<CallScreenCubit, CallScreenState>(
                  listenWhen: (previous, current) =>
                      current.isCallEnded && !previous.isCallEnded,
                  listener: (context, state) =>
                      context.read<WalletCubit>().fetchBalance(),
                  child: SecureAppOverlay(
                    child: Stack(
                      children: [?child, const FloatingCallBubble()],
                    ),
                  ),
                ),
          ),
        );
      },
    );
  }
}
