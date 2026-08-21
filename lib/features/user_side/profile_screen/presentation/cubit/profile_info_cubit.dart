import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/features/auth/domain/repositories/auth_repository.dart';
import 'package:mint_talk/features/user_side/apply_for_host/domain/usecases/check_host_application_eligibility_usecase.dart';

part 'profile_info_state.dart';

@injectable
class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  final AuthRepository _authRepository;
  final CheckHostApplicationEligibilityUseCase _checkHostApplicationEligibilityUseCase;
  final NavigationService _navigationService;

  ProfileInfoCubit(
    this._authRepository,
    this._checkHostApplicationEligibilityUseCase,
    this._navigationService,
  ) : super(const ProfileInfoState());

  Future<void> loadProfileInfo() async {
    emit(state.copyWith(isLoading: true));

    final fullName = await _authRepository.getFullName();
    final phone = await _authRepository.getPhone();
    final referralCode = await _authRepository.getReferralCode();
    final imagePath = await _authRepository.getProfileImagePath();

    emit(
      state.copyWith(
        isLoading: false,
        fullName: fullName,
        phone: phone,
        referralCode: referralCode,
        imagePath: imagePath,
      ),
    );
  }

  /// Routes the "Become a Host" entry point based on cached eligibility
  /// flags: straight to the application status screen if already submitted,
  /// through terms acceptance first if not yet accepted, otherwise straight
  /// to the application form. Throws on failure so the caller can show its
  /// own error UI, matching the previous inline widget behavior.
  Future<void> handleApplyHostTap() async {
    final eligibility = await _checkHostApplicationEligibilityUseCase();
    if (eligibility.hasSubmittedApplication) {
      _navigationService.navigateTo(AppRoutes.hostApplicationStatus);
      return;
    }

    var accepted = eligibility.hasAcceptedTerms;
    if (!accepted) {
      accepted =
          await _navigationService.navigateTo(AppRoutes.termsAndConditionsForHost) == true;
    }
    if (accepted) {
      _navigationService.navigateTo(AppRoutes.applyForHost);
    }
  }
}
