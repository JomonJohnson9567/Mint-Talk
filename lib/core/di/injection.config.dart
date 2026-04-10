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

import '../../features/app_start/presentation/cubit/app_start_cubit.dart'
    as _i57;
import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/send_otp_usecase.dart' as _i663;
import '../../features/auth/domain/usecases/verify_otp_usecase.dart' as _i503;
import '../../features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart'
    as _i91;
import '../../features/auth/presentation/screens/phone_number/presentation/cubit/country_selector_cubit.dart'
    as _i951;
import '../../features/auth/presentation/screens/phone_number/presentation/cubit/phone_form_cubit.dart'
    as _i991;
import '../../features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_cubit.dart'
    as _i453;
import '../../features/user_side/call/presentation/bloc/call_screen_cubit.dart'
    as _i559;
import '../../features/user_side/home/presentation/bloc/home_cubit.dart'
    as _i129;
import '../../features/user_side/profile_setup/presentation/cubit/profile_setup_cubit.dart'
    as _i575;
import '../network/api_client.dart' as _i557;
import '../transitions/cubit/snack_bar_cubit.dart' as _i358;
import '../utils/token_manager.dart' as _i833;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i358.SnackBarCubit>(() => _i358.SnackBarCubit());
    gh.factory<_i951.CountrySelectorCubit>(() => _i951.CountrySelectorCubit());
    gh.factory<_i453.HostProfileSetupCubit>(
      () => _i453.HostProfileSetupCubit(),
    );
    gh.factory<_i559.CallScreenCubit>(() => _i559.CallScreenCubit());
    gh.factory<_i129.HomeCubit>(() => _i129.HomeCubit());
    gh.lazySingleton<_i833.TokenManager>(() => _i833.TokenManager());
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => const _i852.AuthLocalDataSource(),
    );
    gh.lazySingleton<_i557.ApiClient>(
      () => _i557.ApiClient(tokenManager: gh<_i833.TokenManager>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSource(
        gh<_i557.ApiClient>(),
        gh<_i833.TokenManager>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i852.AuthLocalDataSource>(),
        gh<_i833.TokenManager>(),
      ),
    );
    gh.factory<_i575.ProfileSetupCubit>(
      () => _i575.ProfileSetupCubit(gh<_i852.AuthLocalDataSource>()),
    );
    gh.factory<_i57.AppStartCubit>(
      () => _i57.AppStartCubit(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i663.SendOtpUseCase>(
      () => _i663.SendOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i503.VerifyOtpUseCase>(
      () => _i503.VerifyOtpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i91.OtpVerificationCubit>(
      () => _i91.OtpVerificationCubit(
        gh<_i503.VerifyOtpUseCase>(),
        gh<_i663.SendOtpUseCase>(),
      ),
    );
    gh.factory<_i991.PhoneFormCubit>(
      () => _i991.PhoneFormCubit(gh<_i663.SendOtpUseCase>()),
    );
    return this;
  }
}
