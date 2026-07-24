import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_router.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/theme.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard mobile design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [BlocProvider(create: (context) => getIt<WalletCubit>())],
          child: MaterialApp(
            navigatorKey: getIt<NavigationService>().navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Mint Talk',
            theme: AppTheme.lightTheme,
            // home: const HostMainNavigationScreen(),
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          ),
        );
      },
    );
  }
}
