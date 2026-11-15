import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

/// Side effects shared by every screen that lists hosts with a [HomeCubit]:
/// the "Notify Me" snackbar and the post-call host list refresh.
class HostListListeners extends StatelessWidget {
  final Widget child;

  const HostListListeners({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeCubit, HomeState>(
          listenWhen: (previous, current) =>
              previous.notificationId != current.notificationId,
          listener: (context, state) {
            if (state.notificationMessage != null &&
                state.notificationMessage!.isNotEmpty) {
              Color? bgColor;
              if (state.notificationType == NotificationType.info) {
                bgColor = AppColors.termsIcon;
              } else if (state.notificationType == NotificationType.success) {
                bgColor = AppColors.favIcon;
              }
              showTopSnackBar(
                context,
                state.notificationMessage!,
                backgroundColor: bgColor,
              );
            }
          },
        ),
        // The post-call presence snapshot only reports hosts that are still
        // online/busy, so a host who went offline right after the call would
        // keep their stale card. Re-fetch the full list over REST instead —
        // delayed a beat since the backend clears "busy" slightly after /end.
        BlocListener<CallScreenCubit, CallScreenState>(
          listenWhen: (previous, current) =>
              !previous.isCallEnded && current.isCallEnded,
          listener: (context, _) {
            final homeCubit = context.read<HomeCubit>();
            Future.delayed(const Duration(seconds: 2), () {
              if (!homeCubit.isClosed) homeCubit.refresh();
            });
          },
        ),
      ],
      child: child,
    );
  }
}
