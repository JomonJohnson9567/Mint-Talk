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

/// Set on the one [BlockedUsersLoaded] emitted right after a block/unblock
/// succeeds, so listeners can react once (e.g. close the host profile).
enum BlockAction { blocked, unblocked }

class BlockedUsersLoaded extends BlockedUsersState {
  final List<BlockedUserEntity> users;
  final String? actionMessage;
  final BlockAction? lastAction;

  const BlockedUsersLoaded({
    required this.users,
    this.actionMessage,
    this.lastAction,
  });

  @override
  List<Object?> get props => [users, actionMessage, lastAction];
}

class BlockedUsersError extends BlockedUsersState {
  final String message;

  const BlockedUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
