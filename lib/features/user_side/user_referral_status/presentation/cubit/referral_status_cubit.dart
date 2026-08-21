import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';
import 'package:mint_talk/features/user_side/user_referral_status/domain/usecases/get_referral_status_usecase.dart';
import 'referral_status_state.dart';

@injectable
class ReferralStatusCubit extends Cubit<ReferralStatusState> {
  final GetReferralStatusUseCase _getReferralStatusUseCase;
  final AuthRepository _authRepository;

  ReferralStatusCubit(this._getReferralStatusUseCase, this._authRepository)
    : super(const ReferralStatusState());

  Future<void> loadStatus() async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        status: ReferralStatusLoadStatus.loading,
        errorMessage: () => null,
      ),
    );

    final userId = await _authRepository.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: ReferralStatusLoadStatus.failure,
          errorMessage: () => 'User not logged in',
        ),
      );
      return;
    }

    final cachedReferralCode = await _authRepository.getReferralCode();
    final result = await _getReferralStatusUseCase(userId);
    final cachedStatus = _cachedStatus(cachedReferralCode);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: cachedStatus == null
              ? ReferralStatusLoadStatus.failure
              : ReferralStatusLoadStatus.loaded,
          referralStatus: cachedStatus,
          userId: userId,
          errorMessage: () => failure.message,
        ),
      ),
      (referralStatus) {
        final resolvedStatus = referralStatus == null
            ? cachedStatus
            : (referralStatus.hasReferralCode || cachedStatus == null)
            ? referralStatus
            : referralStatus.copyWith(referralCode: cachedStatus.referralCode);
        emit(
          state.copyWith(
            status: ReferralStatusLoadStatus.loaded,
            referralStatus: resolvedStatus,
            userId: userId,
            errorMessage: () => null,
          ),
        );
      },
    );
  }

  ReferralStatusEntity? get currentStatus => state.referralStatus;

  ReferralStatusEntity? _cachedStatus(String? referralCode) {
    if (referralCode == null || referralCode.trim().isEmpty) return null;
    return ReferralStatusEntity(
      rewardPoints: 0,
      status: 'pending',
      referralCode: referralCode.trim(),
    );
  }
}
