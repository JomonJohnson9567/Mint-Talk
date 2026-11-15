import 'dart:async';

import 'package:mint_talk/core/cubit/app_update_cubit.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/widgets/mascot_confirm_sheet.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

bool _promptOpen = false;

/// Shows the prompt matching [cubit]'s current status ("new version
/// available" or "update downloaded"), unless a call is in progress — the
/// app-wide listener in `app.dart` calls this again once the call ends.
Future<void> showAppUpdatePromptIfNeeded(
  AppUpdateCubit cubit,
  CallScreenState callState,
) async {
  final status = cubit.state.status;
  if (status != AppUpdateStatus.available &&
      status != AppUpdateStatus.readyToInstall) {
    return;
  }
  final inCall =
      callState.status != CallScreenStatus.initial && !callState.isCallEnded;
  if (inCall || _promptOpen) return;

  final context =
      getIt<NavigationService>().navigatorKey.currentState?.overlay?.context;
  if (context == null || !context.mounted) return;

  _promptOpen = true;
  try {
    if (status == AppUpdateStatus.available) {
      final update = await MascotConfirmSheet.show(
        context,
        title: 'New version available',
        message:
            'A newer version of MintTalk is on the Play Store. Update now '
            'to get the latest features and fixes.',
        cancelText: 'Later',
        confirmText: 'Update',
      );
      if (update) {
        // Not awaited: it resolves only once the background download ends,
        // and the "Update ready" prompt must be free to open by then.
        unawaited(cubit.startUpdate());
      } else {
        cubit.dismiss();
      }
    } else {
      final restart = await MascotConfirmSheet.show(
        context,
        title: 'Update ready',
        message:
            'The new version has been downloaded. Restart MintTalk to '
            'finish installing it.',
        cancelText: 'Later',
        confirmText: 'Restart now',
      );
      if (restart) await cubit.installNow();
    }
  } finally {
    _promptOpen = false;
  }
}
