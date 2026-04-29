import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/features/user_side/profile_setup/domain/usecases/verify_referral_code.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/referral_state.dart';

@injectable
class ReferralCubit extends Cubit<ReferralState> {
  final VerifyReferralCode _verifyReferralCode;
  
  // Clean handling of debouncing logic
  Timer? _debounceTimer;

  ReferralCubit(this._verifyReferralCode) : super(ReferralInitial());

  /// Handles incoming referral code changes with a 500ms debounce.
  void onReferralCodeChanged(String code) {
    _debounceTimer?.cancel();
    
    if (code.trim().isEmpty) {
      emit(ReferralInitial());
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _verifyCode(code.trim());
    });
  }

  Future<void> _verifyCode(String code) async {
    emit(ReferralLoading());
    
    final result = await _verifyReferralCode(code);

    result.fold(
      (failure) => emit(ReferralInvalid(message: failure.message)),
      (isValid) => isValid 
          ? emit(const ReferralValid()) 
          : emit(const ReferralInvalid(message: 'Invalid referral code')),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
