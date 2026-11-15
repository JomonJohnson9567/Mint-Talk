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
  // One field holds the whole code; the UI draws the boxes from state. A
  // per-box field can't see backspace on an empty box (onChanged never
  // fires), so deleting back across boxes needs a single field.
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  Timer? _resendTimer;
  StreamSubscription<String>? _smsCodeSubscription;
  bool _isInitialized = false;
  String _phone = '';
  String _countryCode = '';

  OtpVerificationCubit(this._verifyOtpUseCase, this._sendOtpUseCase)
    : super(const OtpVerificationState());

  void setCredentials({required String phone, required String countryCode}) {
    _phone = phone;
    _countryCode = countryCode;
  }

  TextEditingController get otpController => _otpController;

  FocusNode get otpFocusNode => _otpFocusNode;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;
    _startInitialTimer();
    _smsCodeSubscription = _smsAutoFill.code.listen(_applyIncomingCode);

    await _smsAutoFill.listenForCode(smsCodeRegexPattern: r'\d{4}');
  }

  void otpChanged(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final code = digits.length > _otpLength
        ? digits.substring(0, _otpLength)
        : digits;

    _syncOtpController(code);

    emit(
      state.copyWith(
        otpDigits: _toDigits(code),
        status: OtpStatus.initial,
        errorMessage: () => null,
      ),
    );

    if (code.length == _otpLength &&
        _phone.isNotEmpty &&
        state.status != OtpStatus.submitting) {
      FocusManager.instance.primaryFocus?.unfocus();
      submitOtp(phone: _phone, countryCode: _countryCode);
    }
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

    final otpCode = normalizedCode.substring(0, _otpLength);
    _syncOtpController(otpCode);
    emit(
      state.copyWith(
        otpDigits: _toDigits(otpCode),
        status: OtpStatus.initial,
        errorMessage: () => null,
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();

    if (_phone.isNotEmpty && state.status != OtpStatus.submitting) {
      submitOtp(phone: _phone, countryCode: _countryCode);
    }
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

  /// "12" → ['1', '2', '', ''].
  List<String> _toDigits(String code) => List.generate(
    _otpLength,
    (index) => index < code.length ? code[index] : '',
  );

  void _syncOtpController(String value) {
    final controller = _otpController;
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
    _otpController.dispose();
    _otpFocusNode.dispose();
    return super.close();
  }
}
