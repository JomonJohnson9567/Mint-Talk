import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/paginated_hosts_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, Unit>> addFavorite(String hostId);
  Future<Either<Failure, Unit>> removeFavorite(String hostId);
  Future<Either<Failure, PaginatedHostsEntity>> getFavoriteHosts({
    int? page,
    int? limit,
  });
}
