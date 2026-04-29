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
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
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
import '../../features/user_side/profile_setup/data/datasources/profile_remote_data_source.dart'
    as _i1000;
import '../../features/user_side/profile_setup/data/repositories/profile_repository_impl.dart'
    as _i388;
import '../../features/user_side/profile_setup/domain/repositories/profile_repository.dart'
    as _i581;
import '../../features/user_side/profile_setup/domain/usecases/create_user_profile.dart'
    as _i55;
import '../../features/user_side/profile_setup/domain/usecases/verify_referral_code.dart'
    as _i141;
import '../../features/user_side/profile_setup/presentation/cubit/profile_cubit.dart'
    as _i253;
import '../../features/user_side/profile_setup/presentation/cubit/referral_cubit.dart'
    as _i199;
import '../../features/user_side/settings/presentation/cubit/logout/logout_cubit.dart'
    as _i117;
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart'
    as _i684;
import '../../features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i690;
import '../../features/wallet/domain/repositories/wallet_repository.dart'
    as _i571;
import '../../features/wallet/domain/usecases/create_order_usecase.dart'
    as _i473;
import '../../features/wallet/domain/usecases/get_plans_usecase.dart' as _i549;
import '../../features/wallet/domain/usecases/get_wallet_balance_usecase.dart'
    as _i820;
import '../../features/wallet/domain/usecases/initialize_wallet_usecase.dart'
    as _i745;
import '../../features/wallet/domain/usecases/verify_payment_usecase.dart'
    as _i305;
import '../../features/wallet/presentation/cubit/wallet_cubit.dart' as _i101;
import '../network/api_client.dart' as _i557;
import '../services/razorpay_service.dart' as _i976;
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
    gh.lazySingleton<_i976.RazorpayService>(() => _i976.RazorpayService());
    gh.lazySingleton<_i833.TokenManager>(() => _i833.TokenManager());
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => const _i852.AuthLocalDataSource(),
    );
    gh.lazySingleton<_i557.ApiClient>(
      () => _i557.ApiClient(tokenManager: gh<_i833.TokenManager>()),
    );
    gh.lazySingleton<_i684.WalletRemoteDataSource>(
      () => _i684.WalletRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i1000.ProfileRemoteDataSource>(
      () => _i1000.ProfileRemoteDataSourceImpl(gh<_i557.ApiClient>()),
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
    gh.lazySingleton<_i581.ProfileRepository>(
      () => _i388.ProfileRepositoryImpl(gh<_i1000.ProfileRemoteDataSource>()),
    );
    gh.factory<_i55.CreateUserProfile>(
      () => _i55.CreateUserProfile(gh<_i581.ProfileRepository>()),
    );
    gh.factory<_i141.VerifyReferralCode>(
      () => _i141.VerifyReferralCode(gh<_i581.ProfileRepository>()),
    );
    gh.lazySingleton<_i571.WalletRepository>(
      () => _i690.WalletRepositoryImpl(gh<_i684.WalletRemoteDataSource>()),
    );
    gh.factory<_i473.CreateOrderUseCase>(
      () => _i473.CreateOrderUseCase(gh<_i571.WalletRepository>()),
    );
    gh.factory<_i549.GetPlansUseCase>(
      () => _i549.GetPlansUseCase(gh<_i571.WalletRepository>()),
    );
    gh.factory<_i820.GetWalletBalanceUseCase>(
      () => _i820.GetWalletBalanceUseCase(gh<_i571.WalletRepository>()),
    );
    gh.factory<_i745.InitializeWalletUseCase>(
      () => _i745.InitializeWalletUseCase(gh<_i571.WalletRepository>()),
    );
    gh.factory<_i305.VerifyPaymentUseCase>(
      () => _i305.VerifyPaymentUseCase(gh<_i571.WalletRepository>()),
    );
    gh.factory<_i199.ReferralCubit>(
      () => _i199.ReferralCubit(gh<_i141.VerifyReferralCode>()),
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
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i101.WalletCubit>(
      () => _i101.WalletCubit(
        initializeWalletUseCase: gh<_i745.InitializeWalletUseCase>(),
        getWalletBalanceUseCase: gh<_i820.GetWalletBalanceUseCase>(),
        createOrderUseCase: gh<_i473.CreateOrderUseCase>(),
        verifyPaymentUseCase: gh<_i305.VerifyPaymentUseCase>(),
        getPlansUseCase: gh<_i549.GetPlansUseCase>(),
        authLocalDataSource: gh<_i852.AuthLocalDataSource>(),
        razorpayService: gh<_i976.RazorpayService>(),
      ),
    );
    gh.factory<_i253.ProfileCubit>(
      () => _i253.ProfileCubit(
        gh<_i55.CreateUserProfile>(),
        gh<_i852.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i117.LogoutCubit>(
      () => _i117.LogoutCubit(gh<_i48.LogoutUseCase>()),
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
