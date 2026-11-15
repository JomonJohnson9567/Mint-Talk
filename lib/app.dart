import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/cubit/app_update_cubit.dart';
import 'package:mint_talk/core/cubit/call_background_ui_cubit.dart';
import 'package:mint_talk/core/cubit/developer_mode_cubit.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_router.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/services/screen_capture/i_screen_capture_guard.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/theme/theme.dart';
import 'package:mint_talk/core/widgets/app_update_prompt.dart';
import 'package:mint_talk/core/widgets/developer_mode_blocked_screen.dart';
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
            // Picture-in-picture mode + "open call" taps from the ongoing
            // call notification (Android).
            BlocProvider(create: (context) => getIt<CallBackgroundUiCubit>()),
            // Play Store update detection (Android). The first check is
            // kicked off by SplashScreen once it navigates away, so the
            // prompt never sits on top of the splash.
            BlocProvider(create: (context) => getIt<AppUpdateCubit>()),
            // Singleton already checked once in main() before runApp, so
            // the first frame is correct; re-checks itself on every resume.
            BlocProvider.value(value: getIt<DeveloperModeCubit>()),
          ],
          child: MaterialApp(
            navigatorKey: getIt<NavigationService>().navigatorKey,
            debugShowCheckedModeBanner: false,
            title: AppTexts.appName,
            theme: AppTheme.lightTheme,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            // App-wide, independent of whether CallScreen or the minimized
            // FloatingCallBubble is what's currently visible (or neither, if
            // the call ended while some other screen was on top) — the
            // server debits/credits points as part of ending the call, so
            // WalletCubit's balance is stale from that moment until this
            // re-fetches it.
            builder: (context, child) => MultiBlocListener(
              listeners: [
                BlocListener<CallScreenCubit, CallScreenState>(
                  listenWhen: (previous, current) =>
                      current.isCallEnded && !previous.isCallEnded,
                  listener: (context, state) =>
                      context.read<WalletCubit>().fetchBalance(),
                ),
                // Entering picture-in-picture or tapping the ongoing-call
                // notification while the call is minimized to the in-app
                // bubble brings the full call screen back, so the PiP
                // window shows the call rather than some other screen.
                BlocListener<CallBackgroundUiCubit, CallBackgroundUiState>(
                  listenWhen: (previous, current) =>
                      (current.isInPip && !previous.isInPip) ||
                      current.openCallRequests != previous.openCallRequests,
                  listener: (context, state) =>
                      restoreMinimizedCall(context.read<CallScreenCubit>()),
                ),
                // "New version available" / "Update ready" prompts.
                BlocListener<AppUpdateCubit, AppUpdateState>(
                  listenWhen: (previous, current) =>
                      previous.status != current.status,
                  listener: (context, state) => showAppUpdatePromptIfNeeded(
                    context.read<AppUpdateCubit>(),
                    context.read<CallScreenCubit>().state,
                  ),
                ),
                // A prompt skipped because a call was in progress is shown
                // once that call ends.
                BlocListener<CallScreenCubit, CallScreenState>(
                  listenWhen: (previous, current) =>
                      current.isCallEnded && !previous.isCallEnded,
                  listener: (context, state) => showAppUpdatePromptIfNeeded(
                    context.read<AppUpdateCubit>(),
                    state,
                  ),
                ),
                // Screenshot / screen-record block for as long as a call is
                // live — including while it's minimised to the floating
                // bubble or shown in picture-in-picture, where the remote
                // video is still visible. CallScreen holds its own claim
                // for the time it's mounted.
                BlocListener<CallScreenCubit, CallScreenState>(
                  listenWhen: (previous, current) =>
                      previous.isCallLive != current.isCallLive,
                  listener: (context, state) {
                    final guard = getIt<IScreenCaptureGuard>();
                    state.isCallLive
                        ? guard.acquire('live_call')
                        : guard.release('live_call');
                  },
                ),
                // Developer options switched on while the app was running
                // (detected on resume): _AppShell swaps the whole app for
                // the block screen, and nothing may keep running behind
                // it — end any call and drop the presence socket so a host
                // doesn't stay online or keep receiving calls.
                BlocListener<DeveloperModeCubit, bool>(
                  listenWhen: (previous, current) => !previous && current,
                  listener: (context, state) {
                    final callCubit = context.read<CallScreenCubit>();
                    if (callCubit.state.isCallLive) callCubit.endCall();
                    getIt<IPresenceSocketService>().disconnect();
                  },
                ),
              ],
              child: _AppShell(child: child),
            ),
          ),
        );
      },
    );
  }
}

/// Wraps every route with the background blur and the floating call bubble.
class _AppShell extends StatelessWidget {
  final Widget? child;

  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    // Developer options on (release Android builds only): the navigator
    // isn't mounted at all, so no screen is reachable and splash / auth /
    // socket never start. Turning them off remounts the navigator at its
    // initial route — a clean restart through the splash auth check.
    final isDeveloperModeBlocked = context.watch<DeveloperModeCubit>().state;
    if (isDeveloperModeBlocked) return const DeveloperModeBlockedScreen();

    final isInPip = context.select<CallBackgroundUiCubit, bool>(
      (c) => c.state.isInPip,
    );
    // An active Android video call auto-enters picture-in-picture when the
    // app is left; the blur would otherwise be what that window shows.
    final pipCapable =
        defaultTargetPlatform == TargetPlatform.android &&
        context.select<CallScreenCubit, bool>((c) => c.state.isPipEligible);

    return SecureAppOverlay(
      enabled: !isInPip && !pipCapable,
      child: Stack(
        children: [?child, if (!isInPip) const FloatingCallBubble()],
      ),
    );
  }
}
