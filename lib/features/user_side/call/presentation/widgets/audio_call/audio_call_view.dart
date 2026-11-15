import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_controls.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_header.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_mascot.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_call/audio_call_status_text.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/audio_route_sheet.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/call_device_status_chips.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_cream_background.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_fit_layout.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/call_network_banner.dart';

/// Full-screen layout for audio calls: cream backdrop, the headset mascot,
/// call status and a frosted controls card. The shared listeners live in
/// `CallScreenContents`.
class AudioCallView extends StatelessWidget {
  final CallScreenState state;

  const AudioCallView({super.key, required this.state});

  bool get _isSettingUp =>
      state.status == CallScreenStatus.initial ||
      state.status == CallScreenStatus.initiating ||
      state.status == CallScreenStatus.ringing ||
      state.status == CallScreenStatus.connecting;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallScreenCubit>();

    return Stack(
      children: [
        const Positioned.fill(child: CallCreamBackground()),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.cw, 12.cw, 24.cw, 16.cw),
            child: Column(
              children: [
                AudioCallHeader(name: state.displayName),
                Expanded(
                  child: CallControlsFirstLayout(
                    // The mascot shrinks to whatever height is left.
                    middle: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 340.cw),
                        child: AudioCallMascot(isFloating: _isSettingUp),
                      ),
                    ),
                    bottom: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AudioCallStatusText(state: state),
                        const CallDeviceStatusChips(),
                        SizedBox(height: 16.cw),
                        AudioCallControls(
                          isMuted: state.isMuted,
                          audioRoute: state.audio.route,
                          isCallActive: state.isCallActive,
                          onToggleMute: cubit.toggleMuteAudio,
                          onAudioRouteTap: () =>
                              AudioRouteSheet.openOrToggle(context),
                          onEndCall: cubit.endCall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8.cw,
          left: 0,
          right: 0,
          child: const CallNetworkBanner(),
        ),
      ],
    );
  }
}
