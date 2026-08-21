import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/get_user_usecase.dart';
import 'user_state.dart';

@injectable
class UserCubit extends Cubit<UserState> {
  final GetUserUseCase getUserUseCase;

  UserCubit(this.getUserUseCase) : super(const UserState.initial());

  Future<void> fetchUser(String id) async {
    emit(const UserState.loading());
    final result = await getUserUseCase(id);
    result.fold(
      (failure) => emit(UserState.error(failure.message)),
      (user) => emit(UserState.loaded(user)),
    );
  }
}
