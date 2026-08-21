import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/screen/host_settings.dart';
import 'package:mint_talk/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/cubit/bottom_nav_cubit.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/screen/host_call_log_screen.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/screens/host_dash.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/widgets/incoming_call_overlay.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_state.dart';

class HostMainNavigationScreen extends StatelessWidget {
  const HostMainNavigationScreen({super.key});

  // Dashboard is the default landing tab.
  static const int _defaultTabIndex = 1;

  final List<Widget> _screens = const [
    HostCallLogScreen(),
    HostDashScreen(),
    HostSettings(),
  ];

  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Exit Mint Talk?',
        content: 'Are you sure you want to close the app?',
        confirmButtonText: 'Yes',
        cancelButtonText: 'No',
        accentColor: Theme.of(context).colorScheme.primary,
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // NotificationsCubit is a single instance provided at the app root (see
    // app.dart), same pattern as WalletCubit on the user side — its status
    // guard makes this a no-op on any later rebuild of this screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationsCubit = context.read<NotificationsCubit>();
      if (notificationsCubit.state.status == NotificationsStatus.initial) {
        notificationsCubit.loadNotifications();
      }
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavCubit()),
        BlocProvider(
          create: (context) => getIt<HostDashCubit>()..loadDashboardData(),
        ),
        BlocProvider(
          create: (context) => getIt<HostProfileCubit>()..loadProfile(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return IncomingCallOverlayListener(
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;
                final navCubit = context.read<BottomNavCubit>();
                if (navCubit.state != _defaultTabIndex) {
                  navCubit.changeTab(_defaultTabIndex);
                  return;
                }
                if (await _confirmExit(context)) {
                  SystemNavigator.pop();
                }
              },
              child: Scaffold(
                extendBody: true, // Allows content to flow behind bottom navigation
                body: BlocBuilder<BottomNavCubit, int>(
                  builder: (context, currentIndex) {
                    return Stack(
                      children: List.generate(_screens.length, (index) {
                        return IgnorePointer(
                          ignoring: index != currentIndex,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: index == currentIndex ? 1.0 : 0.0,
                            curve: Curves.easeInOut,
                            child: _screens[index],
                          ),
                        );
                      }),
                    );
                  },
                ),
                bottomNavigationBar: BlocBuilder<BottomNavCubit, int>(
                  builder: (context, currentIndex) {
                    return CustomBottomNavBar(
                      currentIndex: currentIndex,
                      onTap: (index) {
                        context.read<BottomNavCubit>().changeTab(index);
                      },
                      icons: const [Icons.call, Icons.home_rounded, Icons.settings],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
