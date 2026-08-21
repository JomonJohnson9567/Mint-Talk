import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/cubit/secure_app_overlay_cubit.dart';

/// Blurs the app content whenever it's backgrounded (app-switcher snapshot,
/// another app briefly covering it) so sensitive screens — calls, OTP entry,
/// wallet balances — never appear in the OS recents thumbnail or a momentary
/// peek behind an interruption. Wrap the whole app once (see `app.dart`'s
/// `MaterialApp(builder: ...)`) rather than each sensitive screen individually.
class SecureAppOverlay extends StatelessWidget {
  final Widget? child;

  const SecureAppOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SecureAppOverlayCubit(),
      child: BlocBuilder<SecureAppOverlayCubit, bool>(
        builder: (context, obscured) {
          return Stack(
            children: [
              ?child,
              if (obscured)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Center(
                        child: Image.asset(
                          AppAssets.logo,
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
