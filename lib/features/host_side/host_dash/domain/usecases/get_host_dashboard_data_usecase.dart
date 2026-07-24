import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/host_dashboard_data_entity.dart';
import '../repositories/host_dash_repository.dart';

@injectable
class GetHostDashboardDataUseCase implements UseCase<HostDashboardDataEntity, NoParams> {
  final HostDashRepository repository;

  GetHostDashboardDataUseCase(this.repository);

  @override
  Future<Either<Failure, HostDashboardDataEntity>> call(NoParams params) async {
    return await repository.getDashboardData();
  }
}
