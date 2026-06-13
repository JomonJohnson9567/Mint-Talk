import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

const staging = Environment('staging');

abstract class EnvConfig {
  String get baseUrl;
  String get healthUrl;
  String get razorpayKey;
}

@dev
@LazySingleton(as: EnvConfig)
class DevEnvConfig implements EnvConfig {
  @override
  String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://mint-talk-backend.onrender.com/api/v1';

  @override
  String get healthUrl =>
      dotenv.env['HEALTH_URL'] ?? 'https://mint-talk-backend.onrender.com/health';

  @override
  String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
}

@staging
@LazySingleton(as: EnvConfig)
class StagingEnvConfig implements EnvConfig {
  @override
  String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://staging-mint-talk-backend.onrender.com/api/v1';

  @override
  String get healthUrl =>
      dotenv.env['HEALTH_URL'] ?? 'https://staging-mint-talk-backend.onrender.com/health';

  @override
  String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
}

@prod
@LazySingleton(as: EnvConfig)
class ProdEnvConfig implements EnvConfig {
  @override
  String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'https://mint-talk-backend.onrender.com/api/v1';

  @override
  String get healthUrl =>
      dotenv.env['HEALTH_URL'] ?? 'https://mint-talk-backend.onrender.com/health';

  @override
  String get razorpayKey => dotenv.env['RAZORPAY_KEY'] ?? '';
}
