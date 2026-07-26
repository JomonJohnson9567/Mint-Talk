import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/call/domain/entities/call_session_entity.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_screen_contents.dart';

class CallScreen extends StatelessWidget {
  final String? hostId;
  final String? hostName;
  final String? callType;
  final CallSessionEntity? callSession;
  final bool isHost;

  const CallScreen({
    super.key,
    this.hostId,
    this.hostName,
    this.callType,
    this.callSession,
    this.isHost = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<CallScreenCubit>();
        if (callSession != null) {
          cubit.startIncomingCall(callSession!);
        } else if (hostId != null && callType != null) {
          cubit.startOutgoingCall(
            hostId: hostId!,
            callType: callType!,
          );
        }
        return cubit;
      },
      child: Scaffold(
        backgroundColor: AppColors.callBackground,
        body: CallScreenContents(
          displayName: hostName ?? (isHost ? 'Caller' : 'Host'),
          callType: callType ?? callSession?.callType ?? 'audio',
          isHost: isHost,
        ),
      ),
    );
  }
}
