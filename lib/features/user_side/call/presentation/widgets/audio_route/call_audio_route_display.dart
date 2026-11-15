import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/services/agora/call_audio_route.dart';

/// Icon and label for each audio route, shared by the route button and the
/// route picker sheet.
extension CallAudioRouteDisplay on CallAudioRoute {
  IconData get icon => switch (this) {
    CallAudioRoute.earpiece => Icons.phone_in_talk_rounded,
    CallAudioRoute.speaker => Icons.volume_up_rounded,
    CallAudioRoute.bluetooth => Icons.bluetooth_audio_rounded,
    CallAudioRoute.wiredHeadset => Icons.headset_rounded,
  };

  String get label => switch (this) {
    CallAudioRoute.earpiece => AppTexts.phone,
    CallAudioRoute.speaker => AppTexts.speaker,
    CallAudioRoute.bluetooth => AppTexts.bluetooth,
    CallAudioRoute.wiredHeadset => AppTexts.headset,
  };
}
