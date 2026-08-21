import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';
import 'add_favorite_usecase.dart' show FavoriteHostParams;

@injectable
class RemoveFavoriteUseCase implements UseCase<Unit, FavoriteHostParams> {
  final FavoritesRepository repository;

  RemoveFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(FavoriteHostParams params) {
    return repository.removeFavorite(params.hostId);
  }
}
