import 'package:dartz/dartz.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/paginated_hosts_entity.dart';

abstract class HostRepository {
  Future<Either<Failure, PaginatedHostsEntity>> getOnlineHosts({
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, PaginatedHostsEntity>> getOnCallHosts({
    int page = 1,
    int limit = 20,
  });
}
