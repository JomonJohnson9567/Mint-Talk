import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_screen_contents.dart';

/// The full-screen in-call UI. [CallScreenCubit] is provided once at the app
/// root (see `app.dart`) and outlives this widget — this screen only starts
/// a call the first time it's mounted with start-args (a fresh outgoing call,
/// or an incoming one being accepted); a bubble-triggered restore re-pushes
/// this screen with no args at all, in which case it just re-attaches to the
/// already-running call instead of restarting it.
class CallScreen extends StatefulWidget {
  final String? hostId;
  final String? hostName;
  final String? hostAvatar;
  final CallType? callType;
  final CallSessionEntity? callSession;
  final IncomingCallPayloadDto? incomingPayload;
  final bool isHost;

  const CallScreen({
    super.key,
    this.hostId,
    this.hostName,
    this.hostAvatar,
    this.callType,
    this.callSession,
    this.incomingPayload,
    this.isHost = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    super.initState();

    // Reads the app-root singleton instance via the ancestor BlocProvider —
    // never getIt<CallScreenCubit>() here, which would construct a brand new,
    // disconnected factory instance and silently break minimize/restore.
    final cubit = context.read<CallScreenCubit>();
    final effectiveType =
        widget.callType ??
        widget.callSession?.callType ??
        widget.incomingPayload?.callType ??
        CallType.audio;
    final displayName = widget.hostName ?? (widget.isHost ? 'Caller' : 'Host');

    if (widget.callSession != null) {
      final sessionToStart = widget.callSession!.callType != effectiveType
          ? widget.callSession!.copyWith(callType: effectiveType)
          : widget.callSession!;
      cubit.startIncomingCall(
        sessionToStart,
        displayName: displayName,
        avatarUrl: widget.hostAvatar,
      );
    } else if (widget.incomingPayload != null) {
      cubit.acceptIncomingCall(
        widget.incomingPayload!,
        displayName: displayName,
        avatarUrl: widget.hostAvatar,
      );
    } else if (widget.hostId != null) {
      cubit.startOutgoingCall(
        hostId: widget.hostId!,
        callType: effectiveType,
        displayName: displayName,
        avatarUrl: widget.hostAvatar,
      );
    }

    // Always clear isMinimized — covers both a fresh call and a
    // bubble-triggered restore of an already-running one.
    cubit.restoreCall();

    // Covers restoring from the floating bubble *after* the call already
    // ended/failed while minimized: flutter_bloc's BlocListener (see
    // CallScreenContents) never replays a state that was already current at
    // the moment it subscribed, so a screen mounted straight into an ended
    // state would otherwise never trigger the pop/summary-dialog flow.
    if (cubit.state.isCallEnded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        handleCallEndedTransition(context, cubit.state);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallScreenCubit>();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        if (!cubit.state.isCallEnded) {
          cubit.minimizeCall();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.callBackground,
        body: const CallScreenContents(),
      ),
    );
  }
}
