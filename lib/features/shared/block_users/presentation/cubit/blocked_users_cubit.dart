import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/block_user_usecase.dart';
import '../../domain/usecases/get_blocked_list_usecase.dart';
import '../../domain/usecases/unblock_user_usecase.dart';
import 'blocked_users_state.dart';

@injectable
class BlockedUsersCubit extends Cubit<BlockedUsersState> {
  final GetBlockedListUseCase getBlockedListUseCase;
  final BlockUserUseCase blockUserUseCase;
  final UnblockUserUseCase unblockUserUseCase;

  BlockedUsersCubit({
    required this.getBlockedListUseCase,
    required this.blockUserUseCase,
    required this.unblockUserUseCase,
  }) : super(const BlockedUsersInitial());

  Future<void> loadBlockedUsers() async {
    emit(const BlockedUsersLoading());
    final result = await getBlockedListUseCase(NoParams());

    result.fold(
      (failure) => emit(BlockedUsersError(message: failure.message)),
      (users) => emit(BlockedUsersLoaded(users: users)),
    );
  }

  Future<void> unblockUser(String userId) async {
    final currentState = state;
    if (currentState is! BlockedUsersLoaded) return;

    final result = await unblockUserUseCase(UnblockUserParams(userId: userId));

    result.fold(
      (failure) => emit(BlockedUsersError(message: failure.message)),
      (_) {
        final updatedUsers = currentState.users
            .where((user) => user.blockedId != userId && user.id != userId)
            .toList();
        emit(BlockedUsersLoaded(
          users: updatedUsers,
          actionMessage: 'User unblocked successfully',
        ));
      },
    );
  }

  Future<void> blockUser(String userId) async {
    final result = await blockUserUseCase(BlockUserParams(userId: userId));

    result.fold(
      (failure) => emit(BlockedUsersError(message: failure.message)),
      (_) => loadBlockedUsers(),
    );
  }
}
