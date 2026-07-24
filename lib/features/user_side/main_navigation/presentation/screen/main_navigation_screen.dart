import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/profile_screen/presentation/screen/profile_screen.dart';
import 'package:mint_talk/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/cubit/bottom_nav_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/core/di/injection.dart';

// Import your existing screens here
import 'package:mint_talk/features/user_side/home/presentation/screen/home.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/screen/call_log.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WalletCubit>().fetchBalance();
    });
  }

  final List<Widget> _screens = const [
    CallLogScreen(),
    HomePage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => BottomNavCubit()),
        BlocProvider(create: (context) => getIt<HomeCubit>()),
        BlocProvider(create: (context) => getIt<CallLogCubit>()..loadCallLogs()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
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
          );
        },
      ),
    );
  }
}
