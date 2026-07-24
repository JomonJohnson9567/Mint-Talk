import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/features/host_side/host_settings_screen/presentation/screen/host_settings.dart';
import 'package:mint_talk/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:mint_talk/features/user_side/main_navigation/presentation/cubit/bottom_nav_cubit.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/screen/host_call_log_screen.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/screens/host_dash.dart';
import 'package:mint_talk/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart';

class HostMainNavigationScreen extends StatelessWidget {
  const HostMainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    HostCallLogScreen(),
    HostDashScreen(),


    
    HostSettings(),
  ];

  @override
  Widget build(BuildContext context) {
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
          return Scaffold(
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
          );
        },
      ),
    );
  }
}
