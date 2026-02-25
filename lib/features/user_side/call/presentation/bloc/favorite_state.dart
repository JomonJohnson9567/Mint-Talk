part of 'favorite_cubit.dart';

class FavoriteState {
  final bool isFavorite;

  const FavoriteState({this.isFavorite = false});

  FavoriteState copyWith({bool? isFavorite}) {
    return FavoriteState(isFavorite: isFavorite ?? this.isFavorite);
  }
}
