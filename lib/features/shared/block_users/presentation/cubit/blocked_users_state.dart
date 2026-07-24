import 'package:equatable/equatable.dart';
import '../../domain/entities/blocked_user_entity.dart';

sealed class BlockedUsersState extends Equatable {
  const BlockedUsersState();

  @override
  List<Object?> get props => [];
}

class BlockedUsersInitial extends BlockedUsersState {
  const BlockedUsersInitial();
}

class BlockedUsersLoading extends BlockedUsersState {
  const BlockedUsersLoading();
}

class BlockedUsersLoaded extends BlockedUsersState {
  final List<BlockedUserEntity> users;
  final String? actionMessage;

  const BlockedUsersLoaded({
    required this.users,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [users, actionMessage];
}

class BlockedUsersError extends BlockedUsersState {
  final String message;

  const BlockedUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
