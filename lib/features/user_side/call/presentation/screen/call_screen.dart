import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/data/models/incoming_call_payload_dto.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_type.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_screen_contents.dart';

class CallScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final effectiveType =
        callType ?? callSession?.callType ?? incomingPayload?.callType ?? CallType.audio;

    return BlocProvider(
      create: (context) {
        final cubit = getIt<CallScreenCubit>();
        if (callSession != null) {
          final sessionToStart = callSession!.callType != effectiveType
              ? callSession!.copyWith(callType: effectiveType)
              : callSession!;
          cubit.startIncomingCall(sessionToStart);
        } else if (incomingPayload != null) {
          cubit.acceptIncomingCall(incomingPayload!);
        } else if (hostId != null) {
          cubit.startOutgoingCall(
            hostId: hostId!,
            callType: effectiveType,
          );
        }
        return cubit;
      },
      child: Scaffold(
        backgroundColor: AppColors.callBackground,
        body: CallScreenContents(
          displayName: hostName ?? (isHost ? 'Caller' : 'Host'),
          callType: effectiveType,
          hostAvatar: hostAvatar,
          hostId: hostId,
          isHost: isHost,
        ),
      ),
    );
  }
}
