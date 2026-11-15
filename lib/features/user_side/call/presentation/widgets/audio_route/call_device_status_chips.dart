import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/device_audio/device_audio_models.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call/presentation/bloc/call_screen_cubit.dart';

/// Small chips showing the connected Bluetooth device and the phone's
/// ringer / Do Not Disturb mode. Renders nothing when there's nothing to
/// say (no Bluetooth device, normal ringer — always the case for the mode
/// on iOS, which can't read it).
class CallDeviceStatusChips extends StatelessWidget {
  final bool onDark;

  const CallDeviceStatusChips({super.key, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    final (bluetoothName, soundMode) = context.select(
      (CallScreenCubit c) =>
          (c.state.audio.devices.bluetoothName, c.state.audio.soundMode),
    );
    final modeChip = _modeChip(soundMode);

    if (bluetoothName == null && modeChip == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 8.cw),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.cw,
        runSpacing: 6.cw,
        children: [
          if (bluetoothName != null)
            _StatusChip(
              icon: Icons.bluetooth_connected_rounded,
              label: bluetoothName,
              onDark: onDark,
              semanticLabel: 'Bluetooth connected: $bluetoothName',
            ),
          if (modeChip case (final icon, final label))
            _StatusChip(
              icon: icon,
              label: label,
              onDark: onDark,
              semanticLabel: 'Phone is in $label',
            ),
        ],
      ),
    );
  }

  /// DND wins over the ringer switch — it's the stronger silencer.
  static (IconData, String)? _modeChip(DeviceSoundMode mode) {
    if (mode.isDndOn) {
      return (Icons.do_not_disturb_on_rounded, AppTexts.doNotDisturb);
    }
    return switch (mode.ringerMode) {
      DeviceRingerMode.silent => (
        Icons.notifications_off_rounded,
        AppTexts.silentMode,
      ),
      DeviceRingerMode.vibrate => (
        Icons.vibration_rounded,
        AppTexts.vibrateMode,
      ),
      DeviceRingerMode.normal || DeviceRingerMode.unknown => null,
    };
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool onDark;
  final String semanticLabel;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.onDark,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? AppColors.white : AppColors.plumDeep;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(maxWidth: 200.cw),
        padding: EdgeInsets.symmetric(horizontal: 10.cw, vertical: 5.cw),
        decoration: BoxDecoration(
          color: onDark
              ? AppColors.white.withValues(alpha: 0.16)
              : AppColors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20.cw),
          border: Border.all(
            color: AppColors.white.withValues(alpha: onDark ? 0.2 : 0.9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.cw, color: fg),
            SizedBox(width: 5.cw),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.csp,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
