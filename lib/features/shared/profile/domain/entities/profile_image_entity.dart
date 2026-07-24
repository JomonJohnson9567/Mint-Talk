import 'package:equatable/equatable.dart';

class ProfileImageEntity extends Equatable {
  final String avatarUrl;

  const ProfileImageEntity({required this.avatarUrl});

  @override
  List<Object?> get props => [avatarUrl];
}
