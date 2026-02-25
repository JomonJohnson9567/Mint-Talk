// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/user_side/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart'
    as _i215;
import '../../features/user_side/auth/presentation/screens/phone_number/presentation/cubit/country_selector_cubit.dart'
    as _i390;
import '../../features/user_side/auth/presentation/screens/phone_number/presentation/cubit/phone_form_cubit.dart'
    as _i827;
import '../../features/user_side/call/presentation/bloc/call_screen_cubit.dart'
    as _i559;
import '../../features/user_side/home/presentation/bloc/home_cubit.dart'
    as _i129;
import '../../features/user_side/profile_setup/presentation/cubit/profile_setup_cubit.dart'
    as _i575;
import '../transitions/cubit/snack_bar_cubit.dart' as _i358;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i358.SnackBarCubit>(() => _i358.SnackBarCubit());
    gh.factory<_i215.OtpVerificationCubit>(() => _i215.OtpVerificationCubit());
    gh.factory<_i390.CountrySelectorCubit>(() => _i390.CountrySelectorCubit());
    gh.factory<_i827.PhoneFormCubit>(() => _i827.PhoneFormCubit());
    gh.factory<_i559.CallScreenCubit>(() => _i559.CallScreenCubit());
    gh.factory<_i129.HomeCubit>(() => _i129.HomeCubit());
    gh.factory<_i575.ProfileSetupCubit>(() => _i575.ProfileSetupCubit());
    return this;
  }
}
