import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/paginated_hosts_entity.dart';
import '../repositories/favorites_repository.dart';

class GetFavoriteHostsParams extends Equatable {
  final int? page;
  final int? limit;

  const GetFavoriteHostsParams({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

@injectable
class GetFavoriteHostsUseCase
    implements UseCase<PaginatedHostsEntity, GetFavoriteHostsParams> {
  final FavoritesRepository repository;

  GetFavoriteHostsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedHostsEntity>> call(
    GetFavoriteHostsParams params,
  ) {
    return repository.getFavoriteHosts(page: params.page, limit: params.limit);
  }
}
