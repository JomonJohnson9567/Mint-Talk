import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_view.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_cream_background.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/video_call/video_call_view.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_summary_dialog.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/widgets/recharge_wallet_prompt.dart';

/// Display data (name, avatar, host/caller role) is read from
/// [CallScreenCubit]'s state rather than passed in as constructor args — the
/// cubit lives at the app root and outlives this widget, and a
/// bubble-triggered restore re-mounts this widget with nothing else to
/// source that data from.
class CallScreenContents extends StatelessWidget {
  const CallScreenContents({super.key});

  @override
  Widget build(BuildContext context) {
    // The main listener below only fires on the first transition into an
    // ended state; this one covers the server confirming a balance
    // auto-drop after the call had already ended locally.
    return BlocListener<CallScreenCubit, CallScreenState>(
      listenWhen: (previous, current) =>
          previous.status == CallScreenStatus.ended &&
          current.status == CallScreenStatus.insufficientBalance,
      listener: (context, state) =>
          showTopSnackBar(context, _insufficientBalanceToast(state)),
      child: _buildCallScreen(context),
    );
  }

  Widget _buildCallScreen(BuildContext context) {
    return BlocConsumer<CallScreenCubit, CallScreenState>(
      // Skips rebuilds that are purely the once-a-second duration tick
      // during a healthy active call — nothing this builder renders depends
      // on the duration value itself in that case (each view's timer owns
      // its own narrowly-scoped BlocBuilder).
      buildWhen: (previous, current) {
        final durationOnlyChange =
            previous.durationSeconds != current.durationSeconds &&
            previous.copyWith(durationSeconds: current.durationSeconds) ==
                current;
        final isHealthyActive =
            current.status == CallScreenStatus.active &&
            !current.networkStatus.hasNetworkIssue &&
            current.mediaStatus != CallMediaStatus.reconnecting;
        return !(durationOnlyChange && isHealthyActive);
      },
      listenWhen: (previous, current) {
        final enteredFailed =
            current.status == CallScreenStatus.failed &&
            previous.status != CallScreenStatus.failed;
        final enteredEnded = current.isCallEnded && !previous.isCallEnded;
        return enteredFailed || enteredEnded;
      },
      listener: handleCallEndedTransition,
      builder: (context, state) {
        // There is no post-call screen: the listener pops this route as soon
        // as the call ends, so only a plain backdrop shows for that frame.
        if (state.isCallEnded) return const CallCreamBackground();
        final isVideo =
            (state.session?.callType ?? state.callType ?? CallType.audio)
                .isVideo;
        return isVideo
            ? VideoCallView(state: state)
            : AudioCallView(state: state);
      },
    );
  }
}

String _insufficientBalanceToast(CallScreenState state) => state.isHost
    ? "Call ended: the caller's wallet balance ran out."
    : insufficientBalanceEndedMessage;

/// Runs the call's "just ended/failed" side effects: a snackbar+pop for a
/// failed call, or pop-then-summary-dialog for an ended one. The call screen
/// is always left as soon as the call ends — there is no post-call screen.
///
/// Called from two places: [CallScreenContents]'s own `BlocConsumer`
/// listener, for a live transition while the screen is visible — and from
/// [CallScreen] itself, when it mounts directly into an already-ended state
/// (e.g. restored from the floating bubble after the call ended while
/// minimized). flutter_bloc's `BlocListener` never replays a state that was
/// already current at the time it subscribed, so that second call site is
/// what covers this scenario — without it, a call ending while minimized
/// would silently strand the user on a screen with no exit and no summary.
void handleCallEndedTransition(BuildContext context, CallScreenState state) {
  if (state.status == CallScreenStatus.failed && state.requiresRecharge) {
    // Backend rejected /calls/initiate for low balance — leave the call
    // screen and offer a recharge instead of a generic failure snackbar.
    final navigator = Navigator.of(context);
    navigator.maybePop().then((_) {
      if (!navigator.mounted) return;
      showRechargeWalletPrompt(navigator.context, message: state.errorMessage);
    });
    return;
  }

  if (state.status == CallScreenStatus.failed) {
    final isBusy =
        state.errorMessage.toLowerCase().contains('busy') ||
        state.errorMessage.toLowerCase().contains('another call') ||
        state.errorMessage.toLowerCase().contains('occupied') ||
        state.errorMessage.toLowerCase().contains('400') ||
        state.errorMessage.toLowerCase().contains('409');
    if (isBusy) {
      showTopSnackBar(context, "Host is busy right now. Please try again.");
    } else if (state.errorMessage.isNotEmpty) {
      showTopSnackBar(context, state.errorMessage);
    }
    Navigator.of(context).maybePop();
    return;
  }

  if (!state.isCallEnded) return;

  // Snackbars go into the root overlay, so they outlive the call screen pop.
  // They carry what the removed post-call screen used to say.
  if (state.status == CallScreenStatus.insufficientBalance) {
    showTopSnackBar(context, _insufficientBalanceToast(state));
  } else if (state.errorMessage.isNotEmpty) {
    showTopSnackBar(context, state.errorMessage);
  } else if (state.isNoAnswer) {
    showTopSnackBar(context, "${state.displayName} didn't answer.");
  }

  final cubit = context.read<CallScreenCubit>();
  final wasConnected =
      state.durationSeconds > 0 ||
      state.status == CallScreenStatus.insufficientBalance;
  // The host's summary needs the session's earnings; the caller falls back
  // to a generic dialog without one (see _showCallSummaryDialog).
  final shouldShowSummary =
      wasConnected && (!state.isHost || state.session != null);

  // The call screen route and the summary dialog share the same root
  // Navigator (see NavigationService), so the dialog must be pushed only
  // *after* the call screen has actually been popped — otherwise this
  // deferred pop would land on top of the dialog and dismiss it instead.
  // Deferring to the next frame also keeps the pop from racing the video
  // surface teardown (which previously left the screen frozen).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      // No route to pop (e.g. call screen was the root route) — fall back
      // to the app's navigator so nobody is left stranded on a dead screen.
      getIt<NavigationService>().navigatorKey.currentState?.popUntil(
        (route) => route.isFirst,
      );
    }

    if (!shouldShowSummary) return;
    final globalContext =
        getIt<NavigationService>().navigatorKey.currentContext;
    if (globalContext == null) return;
    _showCallSummaryDialog(globalContext, state).then((_) {
      // Checked once the summary closes rather than from [state]: the
      // balance auto-drop can be confirmed only after the call already ended
      // locally — see CallScreenCubit._handleInsufficientBalance.
      if (state.isHost ||
          cubit.state.status != CallScreenStatus.insufficientBalance) {
        return;
      }
      final rootContext =
          getIt<NavigationService>().navigatorKey.currentContext;
      if (rootContext != null && rootContext.mounted) {
        showRechargeWalletPrompt(
          rootContext,
          message:
              'Your wallet balance ran out during the call. '
              'Recharge to keep talking.',
        );
      }
    });
  });
}

Future<void> _showCallSummaryDialog(
  BuildContext context,
  CallScreenState state,
) {
  final session = state.session;
  if (session != null) {
    return CallSummaryDialog.show(
      context,
      session,
      state.isHost,
      localDurationSeconds: state.durationSeconds,
    );
  } else {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 320.w,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.borderSoft, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                state.status == CallScreenStatus.insufficientBalance
                    ? 'Insufficient Balance'
                    : 'Call Failed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                state.errorMessage.isNotEmpty
                    ? state.errorMessage
                    : 'Could not establish connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.subtitleText,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
