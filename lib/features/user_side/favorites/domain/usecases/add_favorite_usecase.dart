import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/favorites_repository.dart';

class FavoriteHostParams extends Equatable {
  final String hostId;

  const FavoriteHostParams({required this.hostId});

  @override
  List<Object?> get props => [hostId];
}

@injectable
class AddFavoriteUseCase implements UseCase<Unit, FavoriteHostParams> {
  final FavoritesRepository repository;

  AddFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(FavoriteHostParams params) {
    return repository.addFavorite(params.hostId);
  }
}
