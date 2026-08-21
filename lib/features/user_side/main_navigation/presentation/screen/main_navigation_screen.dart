import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/screen/profile_screen.dart';
import 'package:mint_talk/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/cubit/bottom_nav_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:mint_talk/features/shared/notifications/presentation/cubit/notifications_state.dart';
import 'package:mint_talk/core/di/injection.dart';

// Import your existing screens here
import 'package:mint_talk/features/user_side/home/presentation/screen/home.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/screen/call_log.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  // Home is the default landing tab.
  static const int _defaultTabIndex = 1;

  final List<Widget> _screens = const [
    CallLogScreen(),
    HomePage(),
    ProfileScreen(),
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
    // Refresh the wallet balance the first time the authenticated app
    // shell is reached (WalletCubit is a single instance provided at the
    // app root — see app.dart — so it exists before login, and its status
    // guard makes this a no-op on any later rebuild of this screen).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletCubit = context.read<WalletCubit>();
      if (walletCubit.state.status == WalletStatus.initial) {
        walletCubit.fetchBalance();
      }
      final notificationsCubit = context.read<NotificationsCubit>();
      if (notificationsCubit.state.status == NotificationsStatus.initial) {
        notificationsCubit.loadNotifications();
      }
    });

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavCubit()),
        BlocProvider(create: (context) => getIt<HomeCubit>()),
        BlocProvider(create: (context) => getIt<CallLogCubit>()..loadCallLogs()),
      ],
      child: Builder(
        builder: (context) {
          return PopScope(
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
              extendBody:
                  true, // Allows the body to flow behind the floating nav bar
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
                    icons: const [Icons.call, Icons.home_rounded, Icons.person],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
