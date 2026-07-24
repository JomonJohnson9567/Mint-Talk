import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/home/domain/entities/home_user_entity.dart';

class HostOnlineItemEntity extends Equatable {
  final String name;
  final String imageUrl;
  final UserStatus status;

  const HostOnlineItemEntity({
    required this.name,
    required this.imageUrl,
    required this.status,
  });

  @override
  List<Object?> get props => [name, imageUrl, status];
}
