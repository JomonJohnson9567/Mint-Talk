import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/utils/validators.dart';
import 'package:mint_talk/features/auth/domain/entities/auth_response_entity.dart';
import 'package:mint_talk/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:mint_talk/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:mint_talk/features/auth/presentation/utils/auth_flow_helpers.dart';
import 'package:sms_autofill/sms_autofill.dart';

part 'otp_verification_state.dart';

@injectable
class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  static const int _otpLength = 4;

  final VerifyOtpUseCase _verifyOtpUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final SmsAutoFill _smsAutoFill = SmsAutoFill();
  final List<TextEditingController> _otpControllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  Timer? _resendTimer;
  StreamSubscription<String>? _smsCodeSubscription;
  bool _isInitialized = false;

  OtpVerificationCubit(this._verifyOtpUseCase, this._sendOtpUseCase)
    : super(const OtpVerificationState());

  List<TextEditingController> get otpControllers =>
      List<TextEditingController>.unmodifiable(_otpControllers);

  List<FocusNode> get otpFocusNodes =>
      List<FocusNode>.unmodifiable(_otpFocusNodes);

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    _syncOtpControllers(state.otpDigits);
    _startInitialTimer();
    _smsCodeSubscription = _smsAutoFill.code.listen(_applyIncomingCode);

    await _smsAutoFill.listenForCode(smsCodeRegexPattern: r'\d{4}');
  }

  void otpChanged(int index, String value) {
    if (index < 0 || index >= state.otpDigits.length) return;

    final sanitizedValue = value.replaceAll(RegExp(r'\D'), '');
    final updatedDigits = List<String>.from(state.otpDigits);
    final nextValue = sanitizedValue.isEmpty
        ? ''
        : sanitizedValue.substring(sanitizedValue.length - 1);

    updatedDigits[index] = nextValue;
    _syncOtpController(index, nextValue);

    emit(
      state.copyWith(
        otpDigits: updatedDigits,
        status: OtpStatus.initial,
        errorMessage: () => null,
      ),
    );

    _moveFocus(index: index, value: nextValue, otpLength: updatedDigits.length);
  }

  Future<void> submitOtp({
    required String phone,
    required String countryCode,
  }) async {
    final otpCode = state.otpCode;
    final normalizedPhone = AuthFlowHelpers.normalizePhone(phone);
    final normalizedCountryCode = AuthFlowHelpers.normalizeCountryCode(
      countryCode,
    );
    final error = Validators.otp(otpCode);

    if (error != null) {
      emit(
        state.copyWith(status: OtpStatus.invalid, errorMessage: () => error),
      );
      return;
    }

    emit(
      state.copyWith(status: OtpStatus.submitting, errorMessage: () => null),
    );

    final result = await _verifyOtpUseCase(
      VerifyOtpParams(
        phone: normalizedPhone,
        countryCode: normalizedCountryCode,
        otp: otpCode,
      ),
    );

    result.fold(
      (failure) {
        final errorMessage = AuthFlowHelpers.otpFailureMessage(failure);

        emit(
          state.copyWith(
            status: failure is RateLimitFailure
                ? OtpStatus.rateLimited
                : OtpStatus.failure,
            errorMessage: () => errorMessage,
          ),
        );
      },
      (authResponse) {
        emit(
          state.copyWith(
            status: OtpStatus.success,
            authResponse: () => authResponse,
          ),
        );
      },
    );
  }

  Future<void> resendOtp({
    required String phone,
    required String countryCode,
  }) async {
    if (state.resendCooldown > 0) return;

    final normalizedPhone = AuthFlowHelpers.normalizePhone(phone);
    final normalizedCountryCode = AuthFlowHelpers.normalizeCountryCode(
      countryCode,
    );

    emit(state.copyWith(status: OtpStatus.resending, errorMessage: () => null));

    final result = await _sendOtpUseCase(
      SendOtpParams(phone: normalizedPhone, countryCode: normalizedCountryCode),
    );

    result.fold(
      (failure) {
        final errorMessage = AuthFlowHelpers.otpFailureMessage(failure);

        emit(
          state.copyWith(
            status: failure is RateLimitFailure
                ? OtpStatus.rateLimited
                : OtpStatus.failure,
            errorMessage: () => errorMessage,
          ),
        );
      },
      (_) {
        _startResendTimer();
        emit(state.copyWith(status: OtpStatus.resent, resendCooldown: 60));
      },
    );
  }

  void _startInitialTimer() {
    if (state.resendCooldown > 0) return;

    _startResendTimer();
    emit(state.copyWith(resendCooldown: 60));
  }

  void _applyIncomingCode(String code) {
    final normalizedCode = code.replaceAll(RegExp(r'\D'), '');
    if (normalizedCode.length < _otpLength) return;

    final otpDigits = normalizedCode.substring(0, _otpLength).split('');
    _syncOtpControllers(otpDigits);
    emit(
      state.copyWith(
        otpDigits: otpDigits,
        status: OtpStatus.initial,
        errorMessage: () => null,
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newCooldown = state.resendCooldown - 1;

      if (newCooldown <= 0) {
        timer.cancel();
        emit(state.copyWith(resendCooldown: 0));
      } else {
        emit(state.copyWith(resendCooldown: newCooldown));
      }
    });
  }

  void _moveFocus({
    required int index,
    required String value,
    required int otpLength,
  }) {
    if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
      return;
    }

    if (index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  void _syncOtpControllers(List<String> digits) {
    for (var index = 0; index < _otpControllers.length; index++) {
      _syncOtpController(index, digits[index]);
    }
  }

  void _syncOtpController(int index, String value) {
    final controller = _otpControllers[index];
    if (controller.text == value) return;

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  @override
  Future<void> close() async {
    _resendTimer?.cancel();
    await _smsCodeSubscription?.cancel();
    await _smsAutoFill.unregisterListener();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    return super.close();
  }
}
