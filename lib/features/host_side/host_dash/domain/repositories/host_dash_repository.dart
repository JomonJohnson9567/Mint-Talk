import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/host_dashboard_data_entity.dart';
import '../entities/host_preferences_entity.dart';

abstract class HostDashRepository {
  Future<Either<Failure, HostDashboardDataEntity>> getDashboardData();
  Future<Either<Failure, HostPreferencesEntity>> updatePreferences(
    HostPreferencesEntity preferences,
  );
}
