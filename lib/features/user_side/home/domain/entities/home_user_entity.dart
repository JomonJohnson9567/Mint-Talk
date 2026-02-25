enum UserStatus { online, offline, onCall }

class HomeUserEntity {
  final String name;
  final String imageUrl;
  final UserStatus status;
  final bool isFavorite;

  const HomeUserEntity({
    required this.name,
    required this.imageUrl,
    required this.status,
    this.isFavorite = false,
  });
}
