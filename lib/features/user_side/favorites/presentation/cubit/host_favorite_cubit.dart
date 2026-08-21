import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/remove_favorite_usecase.dart';

/// Tracks a single host's favorite status for screens (e.g. the host
/// profile screen) that live outside [HomeCubit]'s provider subtree and so
/// can't share its [HomeState.favoriteIds] set.
@injectable
class HostFavoriteCubit extends Cubit<bool> {
  final AddFavoriteUseCase _addFavoriteUseCase;
  final RemoveFavoriteUseCase _removeFavoriteUseCase;

  HostFavoriteCubit(this._addFavoriteUseCase, this._removeFavoriteUseCase)
      : super(false);

  void setInitial(bool isFavorite) => emit(isFavorite);

  Future<void> toggle(String hostId) async {
    final wasFavorite = state;
    emit(!wasFavorite);

    final params = FavoriteHostParams(hostId: hostId);
    final result = wasFavorite
        ? await _removeFavoriteUseCase(params)
        : await _addFavoriteUseCase(params);

    result.fold((failure) => emit(wasFavorite), (_) {});
  }
}
