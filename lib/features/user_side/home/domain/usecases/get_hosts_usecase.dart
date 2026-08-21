import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/paginated_hosts_entity.dart';
import '../repositories/host_repository.dart';

class GetHostsParams extends Equatable {
  final bool? isOnline;
  final int? page;
  final int? limit;

  const GetHostsParams({
    this.isOnline,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [isOnline, page, limit];
}

@injectable
class GetHostsUseCase implements UseCase<PaginatedHostsEntity, GetHostsParams> {
  final HostRepository repository;

  GetHostsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedHostsEntity>> call(GetHostsParams params) {
    if (params.isOnline == true) {
      return repository.getOnlineHosts(page: params.page, limit: params.limit);
    } else if (params.isOnline == false) {
      return repository.getOnCallHosts(page: params.page, limit: params.limit);
    }
    return repository.getAllHosts(page: params.page, limit: params.limit);
  }
}

