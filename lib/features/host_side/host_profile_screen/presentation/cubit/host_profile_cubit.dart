import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';

import 'host_profile_state.dart';

@injectable
class HostProfileCubit extends Cubit<HostProfileState> {
  final AuthRepository _authRepository;

  HostProfileCubit(this._authRepository) : super(const HostProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: HostProfileStatus.loading, clearError: true));

    try {
      final values = await Future.wait<Object?>([
        _authRepository.getUserId(),
        _authRepository.getFullName(),
        _authRepository.getPhone(),
        _authRepository.getDob(),
        _authRepository.getGender(),
        _authRepository.getRole(),
        _authRepository.getProfileImagePath(),
        _authRepository.getAudioRate(),
        _authRepository.getVideoRate(),
        _authRepository.getIsAudioAllowed(),
        _authRepository.getIsVideoAllowed(),
      ]);

      if (isClosed) return;

      emit(
        HostProfileState(
          status: HostProfileStatus.loaded,
          userId: values[0] as String?,
          fullName: values[1] as String?,
          phone: values[2] as String?,
          dob: values[3] as String?,
          gender: values[4] as String?,
          role: values[5] as String?,
          imagePath: values[6] as String?,
          audioRate: values[7] as int?,
          videoRate: values[8] as int?,
          isAudioAllowed: values[9] as bool?,
          isVideoAllowed: values[10] as bool?,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HostProfileStatus.failure,
          errorMessage: 'Unable to load your host profile.',
        ),
      );
    }
  }
}
