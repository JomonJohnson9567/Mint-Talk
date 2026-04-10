import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/app_start/presentation/cubit/app_start_state.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';

@injectable
class AppStartCubit extends Cubit<AppStartState> {
  final AuthRepository _authRepository;

  AppStartCubit(this._authRepository) : super(const AppStartInitial());

  Future<void> checkAuthStatus() async {
    emit(const AppStartLoading());

    // 1. Check if user is logged in (has valid refresh token)
    final loggedInResult = await _authRepository.checkIsLoggedIn();
    bool isLoggedIn = false;
    
    loggedInResult.fold(
      (failure) {
        emit(AppStartError(message: failure.message));
        return;
      },
      (loggedIn) => isLoggedIn = loggedIn,
    );

    if (state is AppStartError) return;
    
    if (!isLoggedIn) {
      emit(const AppStartUnauthenticated());
      return;
    }

    // 2. Check if OTP is verified
    final otpResult = await _authRepository.checkIsOtpVerified();
    bool isOtpVerified = false;

    otpResult.fold(
      (failure) {
        emit(AppStartError(message: failure.message));
        return;
      },
      (verified) => isOtpVerified = verified,
    );

    if (state is AppStartError) return;

    if (!isOtpVerified) {
      emit(const AppStartUnauthenticated());
      return;
    }

    // 3. Check if profile setup is complete
    final profileResult = await _authRepository.checkIsProfileComplete();
    bool isProfileComplete = false;

    profileResult.fold(
      (failure) {
        emit(AppStartError(message: failure.message));
        return;
      },
      (complete) => isProfileComplete = complete,
    );

    if (state is AppStartError) return;

    if (isProfileComplete) {
      emit(const AppStartAuthenticated());
    } else {
      emit(const AppStartNeedsProfile());
    }
  }
}
