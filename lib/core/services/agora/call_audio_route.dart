/// Where call audio is played. [CallAudioRoute.earpiece] is the phone's
/// receiver (held to the ear), labelled "Phone" in the UI.
enum CallAudioRoute { earpiece, speaker, bluetooth, wiredHeadset }

/// Maps the `routing` int from Agora's `onAudioRoutingChanged` (the
/// `AudioRoute` enum values) to a [CallAudioRoute]. Returns null for the
/// "default" route (-1) and for desktop-only routes, so the caller keeps
/// whatever route it last knew instead of guessing.
CallAudioRoute? callAudioRouteFromAgora(int routing) {
  switch (routing) {
    case 0: // routeHeadset
    case 2: // routeHeadsetnomic
      return CallAudioRoute.wiredHeadset;
    case 1: // routeEarpiece
      return CallAudioRoute.earpiece;
    case 3: // routeSpeakerphone
    case 4: // routeLoudspeaker
      return CallAudioRoute.speaker;
    case 5: // routeBluetoothDeviceHfp
    case 9: // routeAirplay
    case 10: // routeBluetoothDeviceA2dp
      return CallAudioRoute.bluetooth;
    default:
      return null;
  }
}

/// The `route` argument for Agora's Android-only
/// `setRouteInCommunicationMode`.
int agoraCommunicationRouteFor(CallAudioRoute route) {
  switch (route) {
    case CallAudioRoute.wiredHeadset:
      return 0;
    case CallAudioRoute.earpiece:
      return 1;
    case CallAudioRoute.speaker:
      return 3;
    case CallAudioRoute.bluetooth:
      return 5;
  }
}
