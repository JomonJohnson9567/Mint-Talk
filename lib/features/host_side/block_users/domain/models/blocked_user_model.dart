import 'package:equatable/equatable.dart';

class BlockedUserModel extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String blockedReason;

  const BlockedUserModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.blockedReason,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, blockedReason];
}
