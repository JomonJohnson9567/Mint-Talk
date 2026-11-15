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
        _authRepository.getReferralCode(),
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
          referralCode: values[9] as String?,
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
      return;
    }

    if (state.audioRate == null ||
        state.videoRate == null ||
        !state.hasReferralCode) {
      await _syncMissingFields();
    }
  }

  /// Fresh OTP logins skip the launch-time `/user/me` sync, so rates the
  /// login response didn't carry would otherwise stay blank until the host
  /// first goes online — and sessions cached before the backend sent
  /// `referralCode` have no code at all. Fetches them in the background —
  /// the cached profile stays on screen, and a failure just keeps it as is.
  Future<void> _syncMissingFields() async {
    try {
      await _authRepository.syncCurrentUser();
      final values = await Future.wait<Object?>([
        _authRepository.getAudioRate(),
        _authRepository.getVideoRate(),
        _authRepository.getReferralCode(),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          audioRate: values[0] as int?,
          videoRate: values[1] as int?,
          referralCode: values[2] as String?,
        ),
      );
    } catch (_) {
      // Keep the cached state.
    }
  }
}
