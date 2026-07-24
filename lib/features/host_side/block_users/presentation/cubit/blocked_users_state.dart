import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/host_side/block_users/domain/models/blocked_user_model.dart';

abstract class BlockedUsersState extends Equatable {
  const BlockedUsersState();

  @override
  List<Object?> get props => [];
}

class BlockedUsersInitial extends BlockedUsersState {
  const BlockedUsersInitial();
}

class BlockedUsersLoaded extends BlockedUsersState {
  final List<BlockedUserModel> users;

  const BlockedUsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}
