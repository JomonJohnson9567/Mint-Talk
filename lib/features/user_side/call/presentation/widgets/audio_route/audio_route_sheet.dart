import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/agora/call_audio_route.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';
import 'package:mint_talk/features/user_side/call/presentation/widgets/audio_route/call_audio_route_display.dart';

/// Bottom sheet for picking the call's audio output (Phone / Speaker /
/// Bluetooth / Headset). Stays live: a device connecting or the engine
/// switching route while it's open updates the list and the check mark.
class AudioRouteSheet extends StatelessWidget {
  const AudioRouteSheet({super.key});

  /// Opens the picker, or — when there's nothing beyond speaker on/off to
  /// choose from — just toggles the speaker.
  static void openOrToggle(BuildContext context) {
    final cubit = context.read<CallScreenCubit>();
    if (!cubit.state.audio.hasRouteChoice) {
      cubit.toggleSpeakerphone();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const AudioRouteSheet()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CallScreenCubit, CallScreenState>(
      listenWhen: (prev, curr) => !prev.isCallEnded && curr.isCallEnded,
      listener: (context, _) => Navigator.of(context).maybePop(),
      buildWhen: (prev, curr) => prev.audio != curr.audio,
      builder: (context, state) {
        final audio = state.audio;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.homeBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.cw)),
          ),
          padding: EdgeInsets.fromLTRB(16.cw, 10.cw, 16.cw, 12.cw),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.cw,
                    height: 4.cw,
                    decoration: BoxDecoration(
                      color: AppColors.lavenderBorder,
                      borderRadius: BorderRadius.circular(2.cw),
                    ),
                  ),
                ),
                SizedBox(height: 14.cw),
                Text(
                  AppTexts.audioOutput,
                  style: TextStyle(
                    fontSize: 15.csp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.plumDeep,
                  ),
                ),
                SizedBox(height: 8.cw),
                for (final route in audio.availableRoutes)
                  _RouteTile(
                    route: route,
                    subtitle: route == CallAudioRoute.bluetooth
                        ? audio.devices.bluetoothName
                        : null,
                    isSelected: route == audio.route,
                    onTap: () {
                      context.read<CallScreenCubit>().selectAudioRoute(route);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RouteTile extends StatelessWidget {
  final CallAudioRoute route;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _RouteTile({
    required this.route,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primaryColor : AppColors.plumDeep;
    return Semantics(
      selected: isSelected,
      button: true,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.cw),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.cw),
        ),
        tileColor: isSelected ? AppColors.videoBtnBg : null,
        leading: Icon(route.icon, color: color, size: 24.cw),
        title: Text(
          route.label,
          style: TextStyle(
            fontSize: 14.csp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.csp, color: AppColors.plumMuted),
              ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryColor,
                size: 22.cw,
              )
            : null,
      ),
    );
  }
}
