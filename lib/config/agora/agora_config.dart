import 'package:mint_talk/config/env/env_config.dart';

/// Validates the static Agora client configuration.
///
/// Channel names and RTC tokens are intentionally not stored here. The
/// backend returns them per call from `/calls/initiate` and
/// `/calls/:callId/accept`.
class AgoraConfig {
  static const placeholderAppId = 'replace_with_agora_app_id';

  final String appId;

  const AgoraConfig({required this.appId});

  factory AgoraConfig.fromEnvironment(EnvConfig environment) {
    return AgoraConfig(appId: environment.agoraAppId.trim());
  }

  bool get isConfigured =>
      appId != placeholderAppId && RegExp(r'^[a-fA-F0-9]{32}$').hasMatch(appId);

  void ensureConfigured() {
    if (!isConfigured) {
      throw const AgoraConfigurationException();
    }
  }
}

class AgoraConfigurationException implements Exception {
  const AgoraConfigurationException();

  @override
  String toString() =>
      'Agora is not configured. Replace AGORA_APP_ID in the active environment file.';
}
