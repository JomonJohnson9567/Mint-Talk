import 'package:flutter_test/flutter_test.dart';
import 'package:mint_talk/config/agora/agora_config.dart';

void main() {
  group('AgoraConfig', () {
    test('rejects the placeholder App ID', () {
      const config = AgoraConfig(appId: AgoraConfig.placeholderAppId);

      expect(config.isConfigured, isFalse);
      expect(
        config.ensureConfigured,
        throwsA(isA<AgoraConfigurationException>()),
      );
    });

    test('accepts a 32-character hexadecimal App ID', () {
      const config = AgoraConfig(appId: '0123456789abcdef0123456789abcdef');

      expect(config.isConfigured, isTrue);
      expect(config.ensureConfigured, returnsNormally);
    });
  });
}
