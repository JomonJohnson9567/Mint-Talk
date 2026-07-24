import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/host_side/block_users/domain/models/blocked_user_model.dart';
import 'package:mint_talk/features/host_side/block_users/presentation/cubit/blocked_users_state.dart';

class BlockedUsersCubit extends Cubit<BlockedUsersState> {
  BlockedUsersCubit() : super(const BlockedUsersInitial()) {
    _loadUsers();
  }

  static const List<BlockedUserModel> _stubUsers = [
    BlockedUserModel(
      id: '1',
      name: 'Rino George',
      imageUrl: AppAssets.femaleIcon,
      blockedReason: 'Spam calls and repeated interruptions',
    ),
    BlockedUserModel(
      id: '2',
      name: 'Jomon',
      imageUrl: AppAssets.femaleIcon,
      blockedReason: 'Unwanted messages',
    ),
    BlockedUserModel(
      id: '3',
      name: 'Ebson',
      imageUrl: AppAssets.femaleIcon,
      blockedReason: 'Reported for harassment',
    ),
    BlockedUserModel(
      id: '4',
      name: 'Sreejith',
      imageUrl: AppAssets.femaleIcon,
      blockedReason: 'Multiple missed policy warnings',
    ),
  ];

  void _loadUsers() {
    emit(const BlockedUsersLoaded(users: _stubUsers));
  }

  void unblockUser(String userId) {
    final currentState = state;
    if (currentState is! BlockedUsersLoaded) return;

    final updatedUsers = currentState.users
        .where((user) => user.id != userId)
        .toList();

    emit(BlockedUsersLoaded(users: updatedUsers));
  }
}
