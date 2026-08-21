// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../config/env/env_config.dart' as _i145;
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
import '../../features/host_side/apply_for_leave/data/datasources/leave_remote_datasource.dart'
    as _i507;
import '../../features/host_side/apply_for_leave/data/repositories/leave_repository_impl.dart'
    as _i507;
import '../../features/host_side/apply_for_leave/domain/repositories/leave_repository.dart'
    as _i494;
import '../../features/host_side/apply_for_leave/domain/usecases/apply_for_leave_usecase.dart'
    as _i877;
import '../../features/host_side/apply_for_leave/domain/usecases/get_available_days_usecase.dart'
    as _i75;
import '../../features/host_side/apply_for_leave/domain/usecases/get_leave_history_usecase.dart'
    as _i438;
import '../../features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart'
    as _i718;
import '../../features/host_side/chat/presentation/cubit/new_message_picker_cubit.dart'
    as _i864;
import '../../features/host_side/host_call_log_screen/presentation/cubit/host_call_log_cubit.dart'
    as _i575;
import '../../features/host_side/host_dash/data/datasources/host_dash_remote_datasource.dart'
    as _i399;
import '../../features/host_side/host_dash/data/repositories/host_dash_repository_impl.dart'
    as _i935;
import '../../features/host_side/host_dash/domain/repositories/host_dash_repository.dart'
    as _i133;
import '../../features/host_side/host_dash/domain/usecases/get_host_dashboard_data_usecase.dart'
    as _i57;
import '../../features/host_side/host_dash/domain/usecases/update_host_preferences_usecase.dart'
    as _i560;
import '../../features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart'
    as _i986;
import '../../features/host_side/host_perfomance_analytics/data/datasources/performance_analytics_remote_datasource.dart'
    as _i987;
import '../../features/host_side/host_perfomance_analytics/data/repositories/performance_analytics_repository_impl.dart'
    as _i30;
import '../../features/host_side/host_perfomance_analytics/domain/repositories/performance_analytics_repository.dart'
    as _i916;
import '../../features/host_side/host_perfomance_analytics/domain/usecases/get_performance_analytics_usecase.dart'
    as _i299;
import '../../features/host_side/host_perfomance_analytics/presentation/cubit/host_analytics_cubit.dart'
    as _i322;
import '../../features/host_side/host_profile_edit/data/datasources/host_profile_remote_datasource.dart'
    as _i258;
import '../../features/host_side/host_profile_edit/data/repositories/host_profile_repository_impl.dart'
    as _i61;
import '../../features/host_side/host_profile_edit/domain/repositories/host_profile_repository.dart'
    as _i1003;
import '../../features/host_side/host_profile_edit/domain/usecases/get_host_profile_usecase.dart'
    as _i13;
import '../../features/host_side/host_profile_edit/domain/usecases/update_host_profile_usecase.dart'
    as _i502;
import '../../features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart'
    as _i633;
import '../../features/host_side/host_profile_screen/presentation/cubit/host_profile_cubit.dart'
    as _i841;
import '../../features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_cubit.dart'
    as _i453;
import '../../features/host_side/host_targets/data/datasources/host_targets_remote_data_source.dart'
    as _i1011;
import '../../features/host_side/host_targets/data/repositories/host_targets_repository_impl.dart'
    as _i738;
import '../../features/host_side/host_targets/domain/repositories/host_targets_repository.dart'
    as _i1003;
import '../../features/host_side/host_targets/domain/usecases/get_host_targets_usecase.dart'
    as _i431;
import '../../features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart'
    as _i960;
import '../../features/host_side/host_wallet/data/repositories/host_wallet_repository_impl.dart'
    as _i572;
import '../../features/host_side/host_wallet/domain/repositories/host_wallet_repository.dart'
    as _i586;
import '../../features/host_side/host_wallet/domain/usecases/get_host_wallet_overview_usecase.dart'
    as _i933;
import '../../features/host_side/host_wallet/domain/usecases/request_withdrawal_usecase.dart'
    as _i706;
import '../../features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart'
    as _i217;
import '../../features/shared/block_users/data/datasources/block_remote_data_source.dart'
    as _i465;
import '../../features/shared/block_users/data/repositories/block_repository_impl.dart'
    as _i316;
import '../../features/shared/block_users/domain/repositories/block_repository.dart'
    as _i620;
import '../../features/shared/block_users/domain/usecases/block_user_usecase.dart'
    as _i154;
import '../../features/shared/block_users/domain/usecases/get_blocked_list_usecase.dart'
    as _i266;
import '../../features/shared/block_users/domain/usecases/unblock_user_usecase.dart'
    as _i415;
import '../../features/shared/block_users/presentation/cubit/blocked_users_cubit.dart'
    as _i668;
import '../../features/shared/call_report/data/datasources/call_report_remote_data_source.dart'
    as _i879;
import '../../features/shared/call_report/data/repositories/call_report_repository_impl.dart'
    as _i644;
import '../../features/shared/call_report/domain/repositories/call_report_repository.dart'
    as _i858;
import '../../features/shared/call_report/domain/usecases/report_call_misconduct_usecase.dart'
    as _i75;
import '../../features/shared/call_report/presentation/cubit/call_report_cubit.dart'
    as _i945;
import '../../features/shared/chat/data/datasources/chat_remote_data_source.dart'
    as _i14;
import '../../features/shared/chat/data/repositories/chat_repository_impl.dart'
    as _i82;
import '../../features/shared/chat/domain/repositories/chat_repository.dart'
    as _i562;
import '../../features/shared/chat/domain/usecases/get_conversation_messages_usecase.dart'
    as _i1012;
import '../../features/shared/chat/domain/usecases/get_conversations_usecase.dart'
    as _i142;
import '../../features/shared/chat/domain/usecases/get_predefined_messages_usecase.dart'
    as _i253;
import '../../features/shared/chat/domain/usecases/mark_conversation_read_usecase.dart'
    as _i711;
import '../../features/shared/chat/domain/usecases/mark_messages_delivered_usecase.dart'
    as _i309;
import '../../features/shared/chat/domain/usecases/send_message_usecase.dart'
    as _i26;
import '../../features/shared/chat/domain/usecases/watch_new_messages_usecase.dart'
    as _i224;
import '../../features/shared/chat/presentation/cubit/conversations_cubit.dart'
    as _i834;
import '../../features/shared/notifications/data/datasources/notifications_remote_data_source.dart'
    as _i319;
import '../../features/shared/notifications/data/repositories/notifications_repository_impl.dart'
    as _i563;
import '../../features/shared/notifications/domain/repositories/notifications_repository.dart'
    as _i952;
import '../../features/shared/notifications/domain/usecases/get_notifications_usecase.dart'
    as _i791;
import '../../features/shared/notifications/domain/usecases/get_unread_count_usecase.dart'
    as _i300;
import '../../features/shared/notifications/domain/usecases/mark_all_notifications_read_usecase.dart'
    as _i279;
import '../../features/shared/notifications/domain/usecases/mark_notification_read_usecase.dart'
    as _i1029;
import '../../features/shared/notifications/domain/usecases/watch_new_notifications_usecase.dart'
    as _i1050;
import '../../features/shared/notifications/presentation/cubit/notifications_cubit.dart'
    as _i611;
import '../../features/shared/profile/data/datasources/profile_remote_data_source.dart'
    as _i862;
import '../../features/shared/profile/data/repositories/profile_repository_impl.dart'
    as _i721;
import '../../features/shared/profile/domain/repositories/profile_repository.dart'
    as _i418;
import '../../features/shared/profile/domain/usecases/upload_profile_image_usecase.dart'
    as _i32;
import '../../features/shared/profile/presentation/cubit/profile_image_cubit.dart'
    as _i62;
import '../../features/user_side/apply_for_host/data/datasources/host_application_local_datasource.dart'
    as _i327;
import '../../features/user_side/apply_for_host/data/datasources/host_application_remote_datasource.dart'
    as _i199;
import '../../features/user_side/apply_for_host/data/repositories/host_application_repository_impl.dart'
    as _i234;
import '../../features/user_side/apply_for_host/domain/repositories/host_application_repository.dart'
    as _i456;
import '../../features/user_side/apply_for_host/domain/usecases/accept_host_terms_usecase.dart'
    as _i779;
import '../../features/user_side/apply_for_host/domain/usecases/check_host_application_eligibility_usecase.dart'
    as _i200;
import '../../features/user_side/apply_for_host/domain/usecases/get_host_application_status_usecase.dart'
    as _i1032;
import '../../features/user_side/apply_for_host/domain/usecases/submit_host_application_usecase.dart'
    as _i211;
import '../../features/user_side/apply_for_host/domain/usecases/upload_image_usecase.dart'
    as _i340;
import '../../features/user_side/apply_for_host/presentation/cubit/apply_for_host_cubit.dart'
    as _i891;
import '../../features/user_side/apply_for_host/presentation/cubit/host_application_status_cubit.dart'
    as _i821;
import '../../features/user_side/call/data/datasources/call_remote_data_source.dart'
    as _i449;
import '../../features/user_side/call/data/repositories/call_repository_impl.dart'
    as _i544;
import '../../features/user_side/call/domain/repositories/i_call_repository.dart'
    as _i294;
import '../../features/user_side/call/domain/usecases/accept_call_usecase.dart'
    as _i106;
import '../../features/user_side/call/domain/usecases/activate_call_usecase.dart'
    as _i415;
import '../../features/user_side/call/domain/usecases/cancel_call_usecase.dart'
    as _i692;
import '../../features/user_side/call/domain/usecases/end_call_usecase.dart'
    as _i1018;
import '../../features/user_side/call/domain/usecases/get_call_details_usecase.dart'
    as _i830;
import '../../features/user_side/call/domain/usecases/initiate_call_usecase.dart'
    as _i866;
import '../../features/user_side/call/domain/usecases/reject_call_usecase.dart'
    as _i97;
import '../../features/user_side/call/presentation/bloc/call_screen_cubit.dart'
    as _i559;
import '../../features/user_side/call_log/data/datasources/call_log_remote_data_source.dart'
    as _i554;
import '../../features/user_side/call_log/data/repositories/call_log_repository_impl.dart'
    as _i493;
import '../../features/user_side/call_log/domain/repositories/call_log_repository.dart'
    as _i271;
import '../../features/user_side/call_log/domain/usecases/get_call_statistics_usecase.dart'
    as _i1021;
import '../../features/user_side/call_log/domain/usecases/get_host_call_logs_usecase.dart'
    as _i148;
import '../../features/user_side/call_log/domain/usecases/get_user_call_logs_usecase.dart'
    as _i67;
import '../../features/user_side/call_log/presentation/bloc/call_log_cubit.dart'
    as _i610;
import '../../features/user_side/favorites/data/datasources/favorites_remote_data_source.dart'
    as _i269;
import '../../features/user_side/favorites/data/repositories/favorites_repository_impl.dart'
    as _i342;
import '../../features/user_side/favorites/domain/repositories/favorites_repository.dart'
    as _i949;
import '../../features/user_side/favorites/domain/usecases/add_favorite_usecase.dart'
    as _i381;
import '../../features/user_side/favorites/domain/usecases/get_favorite_hosts_usecase.dart'
    as _i381;
import '../../features/user_side/favorites/domain/usecases/remove_favorite_usecase.dart'
    as _i193;
import '../../features/user_side/favorites/presentation/cubit/host_favorite_cubit.dart'
    as _i454;
import '../../features/user_side/home/data/datasources/host_remote_data_source.dart'
    as _i884;
import '../../features/user_side/home/data/repositories/host_repository_impl.dart'
    as _i894;
import '../../features/user_side/home/domain/repositories/host_repository.dart'
    as _i136;
import '../../features/user_side/home/domain/usecases/connect_host_presence_usecase.dart'
    as _i725;
import '../../features/user_side/home/domain/usecases/disconnect_host_presence_usecase.dart'
    as _i369;
import '../../features/user_side/home/domain/usecases/get_hosts_usecase.dart'
    as _i663;
import '../../features/user_side/home/domain/usecases/watch_host_presence_usecase.dart'
    as _i562;
import '../../features/user_side/home/presentation/bloc/home_cubit.dart'
    as _i129;
import '../../features/user_side/online_users/presentation/cubit/online_users_cubit.dart'
    as _i964;
import '../../features/user_side/profile_screen/presentation/cubit/profile_info_cubit.dart'
    as _i746;
import '../../features/user_side/profile_setup/data/datasources/profile_remote_data_source.dart'
    as _i1000;
import '../../features/user_side/profile_setup/data/repositories/profile_repository_impl.dart'
    as _i388;
import '../../features/user_side/profile_setup/domain/repositories/profile_repository.dart'
    as _i581;
import '../../features/user_side/profile_setup/domain/usecases/create_user_profile.dart'
    as _i55;
import '../../features/user_side/profile_setup/domain/usecases/update_user_profile.dart'
    as _i599;
import '../../features/user_side/profile_setup/domain/usecases/verify_referral_code.dart'
    as _i141;
import '../../features/user_side/profile_setup/presentation/cubit/profile_cubit.dart'
    as _i253;
import '../../features/user_side/profile_setup/presentation/cubit/referral_cubit.dart'
    as _i199;
import '../../features/user_side/recharge_plans/presentation/cubit/plan_detail_cubit.dart'
    as _i381;
import '../../features/user_side/settings/presentation/cubit/logout/logout_cubit.dart'
    as _i117;
import '../../features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_cubit.dart'
    as _i1036;
import '../../features/user_side/user_recharge_history/data/datasources/recharge_history_remote_datasource.dart'
    as _i259;
import '../../features/user_side/user_recharge_history/data/repositories/recharge_history_repository_impl.dart'
    as _i338;
import '../../features/user_side/user_recharge_history/domain/repositories/recharge_history_repository.dart'
    as _i649;
import '../../features/user_side/user_recharge_history/domain/usecases/get_recharge_history_usecase.dart'
    as _i481;
import '../../features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_cubit.dart'
    as _i276;
import '../../features/user_side/user_referral_status/data/datasources/referral_status_remote_datasource.dart'
    as _i924;
import '../../features/user_side/user_referral_status/data/repositories/referral_status_repository_impl.dart'
    as _i553;
import '../../features/user_side/user_referral_status/domain/repositories/referral_status_repository.dart'
    as _i33;
import '../../features/user_side/user_referral_status/domain/usecases/get_referral_status_usecase.dart'
    as _i790;
import '../../features/user_side/user_referral_status/presentation/cubit/referral_status_cubit.dart'
    as _i497;
import '../../features/user_side/wallet/data/datasources/wallet_remote_datasource.dart'
    as _i1043;
import '../../features/user_side/wallet/data/repositories/wallet_repository_impl.dart'
    as _i1050;
import '../../features/user_side/wallet/domain/repositories/wallet_repository.dart'
    as _i261;
import '../../features/user_side/wallet/domain/usecases/create_order_usecase.dart'
    as _i961;
import '../../features/user_side/wallet/domain/usecases/get_plan_by_id_usecase.dart'
    as _i523;
import '../../features/user_side/wallet/domain/usecases/get_plans_usecase.dart'
    as _i284;
import '../../features/user_side/wallet/domain/usecases/get_wallet_balance_usecase.dart'
    as _i98;
import '../../features/user_side/wallet/domain/usecases/initialize_wallet_usecase.dart'
    as _i601;
import '../../features/user_side/wallet/domain/usecases/verify_payment_usecase.dart'
    as _i821;
import '../../features/user_side/wallet/presentation/cubit/wallet_cubit.dart'
    as _i285;
import '../navigations/navigation_service.dart' as _i173;
import '../network/api_client.dart' as _i557;
import '../network/dio_provider.dart' as _i651;
import '../services/agora/agora_service.dart' as _i449;
import '../services/agora/i_agora_service.dart' as _i10;
import '../services/connectivity/connectivity_service.dart' as _i1015;
import '../services/permissions/call_permission_service.dart' as _i405;
import '../services/razorpay_service.dart' as _i976;
import '../services/socket/i_presence_socket_service.dart' as _i541;
import '../services/socket/presence_socket_service.dart' as _i349;
import '../transitions/cubit/snack_bar_cubit.dart' as _i358;
import '../utils/token_manager.dart' as _i833;
import 'storage_module.dart' as _i371;

const String _staging = 'staging';
const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final storageModule = _$StorageModule();
    final dioModule = _$DioModule();
    gh.factory<_i358.SnackBarCubit>(() => _i358.SnackBarCubit());
    gh.factory<_i951.CountrySelectorCubit>(() => _i951.CountrySelectorCubit());
    gh.factory<_i453.HostProfileSetupCubit>(
      () => _i453.HostProfileSetupCubit(),
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => storageModule.secureStorage,
    );
    gh.lazySingleton<_i173.NavigationService>(() => _i173.NavigationService());
    gh.lazySingleton<_i361.Dio>(() => dioModule.dio);
    gh.lazySingleton<_i976.RazorpayService>(() => _i976.RazorpayService());
    gh.lazySingleton<_i1015.IConnectivityService>(
      () => _i1015.ConnectivityService(),
    );
    gh.lazySingleton<_i10.IAgoraService>(() => _i449.AgoraService());
    gh.lazySingleton<_i145.EnvConfig>(
      () => _i145.StagingEnvConfig(),
      registerFor: {_staging},
    );
    gh.lazySingleton<_i852.IAuthLocalDataSource>(
      () => const _i852.AuthLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i405.ICallPermissionService>(
      () => _i405.CallPermissionService(),
    );
    gh.lazySingleton<_i557.ApiClient>(() => _i557.ApiClient(gh<_i361.Dio>()));
    gh.lazySingleton<_i399.HostDashRemoteDataSource>(
      () => _i399.HostDashRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i145.EnvConfig>(
      () => _i145.DevEnvConfig(),
      registerFor: {_dev},
    );
    gh.lazySingleton<_i259.RechargeHistoryRemoteDataSource>(
      () => _i259.RechargeHistoryRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i924.ReferralStatusRemoteDataSource>(
      () => _i924.ReferralStatusRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i833.TokenManager>(
      () => _i833.TokenManager(secureStorage: gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i327.HostApplicationLocalDataSource>(
      () => _i327.HostApplicationLocalDataSourceImpl(
        gh<_i852.IAuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i145.EnvConfig>(
      () => _i145.ProdEnvConfig(),
      registerFor: {_prod},
    );
    gh.factory<_i964.OnlineUsersCubit>(
      () =>
          _i964.OnlineUsersCubit(getHostsUseCase: gh<_i663.GetHostsUseCase>()),
    );
    gh.lazySingleton<_i649.RechargeHistoryRepository>(
      () => _i338.RechargeHistoryRepositoryImpl(
        gh<_i259.RechargeHistoryRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i541.IPresenceSocketService>(
      () => _i349.PresenceSocketService(
        gh<_i145.EnvConfig>(),
        gh<_i833.TokenManager>(),
      ),
    );
    gh.lazySingleton<_i133.HostDashRepository>(
      () => _i935.HostDashRepositoryImpl(gh<_i399.HostDashRemoteDataSource>()),
    );
    gh.lazySingleton<_i1043.WalletRemoteDataSource>(
      () => _i1043.WalletRemoteDataSourceImpl(
        gh<_i557.ApiClient>(),
        gh<_i145.EnvConfig>(),
      ),
    );
    gh.lazySingleton<_i884.HostRemoteDataSource>(
      () => _i884.HostRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i57.GetHostDashboardDataUseCase>(
      () => _i57.GetHostDashboardDataUseCase(gh<_i133.HostDashRepository>()),
    );
    gh.factory<_i560.UpdateHostPreferencesUseCase>(
      () => _i560.UpdateHostPreferencesUseCase(gh<_i133.HostDashRepository>()),
    );
    gh.lazySingleton<_i987.PerformanceAnalyticsRemoteDataSource>(
      () =>
          _i987.PerformanceAnalyticsRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i319.NotificationsRemoteDataSource>(
      () => _i319.NotificationsRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i33.ReferralStatusRepository>(
      () => _i553.ReferralStatusRepositoryImpl(
        gh<_i924.ReferralStatusRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i507.LeaveRemoteDataSource>(
      () => _i507.LeaveRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i449.ICallRemoteDataSource>(
      () => _i449.CallRemoteDataSource(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i862.ProfileRemoteDataSource>(
      () => _i862.ProfileRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i199.HostApplicationRemoteDataSource>(
      () => _i199.HostApplicationRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i269.FavoritesRemoteDataSource>(
      () => _i269.FavoritesRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i465.BlockRemoteDataSource>(
      () => _i465.BlockRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i879.CallReportRemoteDataSource>(
      () => _i879.CallReportRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.factory<_i481.GetRechargeHistoryUseCase>(
      () => _i481.GetRechargeHistoryUseCase(
        gh<_i649.RechargeHistoryRepository>(),
      ),
    );
    gh.lazySingleton<_i858.CallReportRepository>(
      () => _i644.CallReportRepositoryImpl(
        gh<_i879.CallReportRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i107.IAuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSourceImpl(
        gh<_i557.ApiClient>(),
        gh<_i833.TokenManager>(),
      ),
    );
    gh.lazySingleton<_i1011.HostTargetsRemoteDataSource>(
      () => _i1011.HostTargetsRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i554.CallLogRemoteDataSource>(
      () => _i554.CallLogRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i136.HostRepository>(
      () => _i894.HostRepositoryImpl(
        gh<_i884.HostRemoteDataSource>(),
        gh<_i541.IPresenceSocketService>(),
      ),
    );
    gh.lazySingleton<_i14.ChatRemoteDataSource>(
      () => _i14.ChatRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i258.HostProfileRemoteDataSource>(
      () => _i258.HostProfileRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i1003.HostProfileRepository>(
      () => _i61.HostProfileRepositoryImpl(
        gh<_i258.HostProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i562.ChatRepository>(
      () => _i82.ChatRepositoryImpl(
        gh<_i14.ChatRemoteDataSource>(),
        gh<_i541.IPresenceSocketService>(),
      ),
    );
    gh.lazySingleton<_i1000.ProfileRemoteDataSource>(
      () => _i1000.ProfileRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i960.HostWalletRemoteDataSource>(
      () => _i960.HostWalletRemoteDataSourceImpl(gh<_i557.ApiClient>()),
    );
    gh.lazySingleton<_i952.NotificationsRepository>(
      () => _i563.NotificationsRepositoryImpl(
        gh<_i319.NotificationsRemoteDataSource>(),
        gh<_i541.IPresenceSocketService>(),
      ),
    );
    gh.lazySingleton<_i261.WalletRepository>(
      () => _i1050.WalletRepositoryImpl(gh<_i1043.WalletRemoteDataSource>()),
    );
    gh.lazySingleton<_i949.FavoritesRepository>(
      () =>
          _i342.FavoritesRepositoryImpl(gh<_i269.FavoritesRemoteDataSource>()),
    );
    gh.lazySingleton<_i620.BlockRepository>(
      () => _i316.BlockRepositoryImpl(gh<_i465.BlockRemoteDataSource>()),
    );
    gh.lazySingleton<_i1003.HostTargetsRepository>(
      () => _i738.HostTargetsRepositoryImpl(
        gh<_i1011.HostTargetsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i586.HostWalletRepository>(
      () => _i572.HostWalletRepositoryImpl(
        gh<_i960.HostWalletRemoteDataSource>(),
      ),
    );
    gh.factory<_i790.GetReferralStatusUseCase>(
      () => _i790.GetReferralStatusUseCase(gh<_i33.ReferralStatusRepository>()),
    );
    gh.factory<_i154.BlockUserUseCase>(
      () => _i154.BlockUserUseCase(gh<_i620.BlockRepository>()),
    );
    gh.factory<_i266.GetBlockedListUseCase>(
      () => _i266.GetBlockedListUseCase(gh<_i620.BlockRepository>()),
    );
    gh.factory<_i415.UnblockUserUseCase>(
      () => _i415.UnblockUserUseCase(gh<_i620.BlockRepository>()),
    );
    gh.factory<_i791.GetNotificationsUseCase>(
      () => _i791.GetNotificationsUseCase(gh<_i952.NotificationsRepository>()),
    );
    gh.factory<_i300.GetUnreadCountUseCase>(
      () => _i300.GetUnreadCountUseCase(gh<_i952.NotificationsRepository>()),
    );
    gh.factory<_i279.MarkAllNotificationsReadUseCase>(
      () => _i279.MarkAllNotificationsReadUseCase(
        gh<_i952.NotificationsRepository>(),
      ),
    );
    gh.factory<_i1029.MarkNotificationReadUseCase>(
      () => _i1029.MarkNotificationReadUseCase(
        gh<_i952.NotificationsRepository>(),
      ),
    );
    gh.factory<_i961.CreateOrderUseCase>(
      () => _i961.CreateOrderUseCase(gh<_i261.WalletRepository>()),
    );
    gh.factory<_i523.GetPlanByIdUseCase>(
      () => _i523.GetPlanByIdUseCase(gh<_i261.WalletRepository>()),
    );
    gh.factory<_i284.GetPlansUseCase>(
      () => _i284.GetPlansUseCase(gh<_i261.WalletRepository>()),
    );
    gh.factory<_i98.GetWalletBalanceUseCase>(
      () => _i98.GetWalletBalanceUseCase(gh<_i261.WalletRepository>()),
    );
    gh.factory<_i601.InitializeWalletUseCase>(
      () => _i601.InitializeWalletUseCase(gh<_i261.WalletRepository>()),
    );
    gh.factory<_i821.VerifyPaymentUseCase>(
      () => _i821.VerifyPaymentUseCase(gh<_i261.WalletRepository>()),
    );
    gh.lazySingleton<_i916.PerformanceAnalyticsRepository>(
      () => _i30.PerformanceAnalyticsRepositoryImpl(
        gh<_i987.PerformanceAnalyticsRemoteDataSource>(),
      ),
    );
    gh.factory<_i13.GetHostProfileUseCase>(
      () => _i13.GetHostProfileUseCase(gh<_i1003.HostProfileRepository>()),
    );
    gh.factory<_i502.UpdateHostProfileUseCase>(
      () => _i502.UpdateHostProfileUseCase(gh<_i1003.HostProfileRepository>()),
    );
    gh.lazySingleton<_i494.LeaveRepository>(
      () => _i507.LeaveRepositoryImpl(gh<_i507.LeaveRemoteDataSource>()),
    );
    gh.lazySingleton<_i581.ProfileRepository>(
      () => _i388.ProfileRepositoryImpl(gh<_i1000.ProfileRemoteDataSource>()),
    );
    gh.factory<_i381.AddFavoriteUseCase>(
      () => _i381.AddFavoriteUseCase(gh<_i949.FavoritesRepository>()),
    );
    gh.factory<_i381.GetFavoriteHostsUseCase>(
      () => _i381.GetFavoriteHostsUseCase(gh<_i949.FavoritesRepository>()),
    );
    gh.factory<_i193.RemoveFavoriteUseCase>(
      () => _i193.RemoveFavoriteUseCase(gh<_i949.FavoritesRepository>()),
    );
    gh.factory<_i877.ApplyForLeaveUseCase>(
      () => _i877.ApplyForLeaveUseCase(gh<_i494.LeaveRepository>()),
    );
    gh.factory<_i75.GetAvailableDaysUseCase>(
      () => _i75.GetAvailableDaysUseCase(gh<_i494.LeaveRepository>()),
    );
    gh.factory<_i438.GetLeaveHistoryUseCase>(
      () => _i438.GetLeaveHistoryUseCase(gh<_i494.LeaveRepository>()),
    );
    gh.lazySingleton<_i418.ProfileRepository>(
      () => _i721.ProfileRepositoryImpl(gh<_i862.ProfileRemoteDataSource>()),
    );
    gh.factory<_i55.CreateUserProfile>(
      () => _i55.CreateUserProfile(gh<_i581.ProfileRepository>()),
    );
    gh.factory<_i599.UpdateUserProfile>(
      () => _i599.UpdateUserProfile(gh<_i581.ProfileRepository>()),
    );
    gh.factory<_i141.VerifyReferralCode>(
      () => _i141.VerifyReferralCode(gh<_i581.ProfileRepository>()),
    );
    gh.factory<_i381.PlanDetailCubit>(
      () => _i381.PlanDetailCubit(gh<_i523.GetPlanByIdUseCase>()),
    );
    gh.factory<_i668.BlockedUsersCubit>(
      () => _i668.BlockedUsersCubit(
        getBlockedListUseCase: gh<_i266.GetBlockedListUseCase>(),
        blockUserUseCase: gh<_i154.BlockUserUseCase>(),
        unblockUserUseCase: gh<_i415.UnblockUserUseCase>(),
      ),
    );
    gh.lazySingleton<_i294.ICallRepository>(
      () => _i544.CallRepositoryImpl(
        gh<_i449.ICallRemoteDataSource>(),
        gh<_i541.IPresenceSocketService>(),
      ),
    );
    gh.lazySingleton<_i106.AcceptCallUseCase>(
      () => _i106.AcceptCallUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i415.ActivateCallUseCase>(
      () => _i415.ActivateCallUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i692.CancelCallUseCase>(
      () => _i692.CancelCallUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i1018.EndCallUseCase>(
      () => _i1018.EndCallUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i830.GetCallDetailsUseCase>(
      () => _i830.GetCallDetailsUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i866.InitiateCallUseCase>(
      () => _i866.InitiateCallUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i97.RejectCallUseCase>(
      () => _i97.RejectCallUseCase(gh<_i294.ICallRepository>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.IAuthRemoteDataSource>(),
        gh<_i852.IAuthLocalDataSource>(),
        gh<_i833.TokenManager>(),
        gh<_i541.IPresenceSocketService>(),
      ),
    );
    gh.factory<_i224.WatchNewMessagesUseCase>(
      () => _i224.WatchNewMessagesUseCase(gh<_i562.ChatRepository>()),
    );
    gh.lazySingleton<_i456.HostApplicationRepository>(
      () => _i234.HostApplicationRepositoryImpl(
        gh<_i199.HostApplicationRemoteDataSource>(),
        gh<_i327.HostApplicationLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i271.CallLogRepository>(
      () => _i493.CallLogRepositoryImpl(gh<_i554.CallLogRemoteDataSource>()),
    );
    gh.factory<_i933.GetHostWalletOverviewUseCase>(
      () =>
          _i933.GetHostWalletOverviewUseCase(gh<_i586.HostWalletRepository>()),
    );
    gh.factory<_i706.RequestWithdrawalUseCase>(
      () => _i706.RequestWithdrawalUseCase(gh<_i586.HostWalletRepository>()),
    );
    gh.factory<_i725.ConnectHostPresenceUseCase>(
      () => _i725.ConnectHostPresenceUseCase(gh<_i136.HostRepository>()),
    );
    gh.factory<_i369.DisconnectHostPresenceUseCase>(
      () => _i369.DisconnectHostPresenceUseCase(gh<_i136.HostRepository>()),
    );
    gh.factory<_i562.WatchHostPresenceUseCase>(
      () => _i562.WatchHostPresenceUseCase(gh<_i136.HostRepository>()),
    );
    gh.factory<_i75.ReportCallMisconductUseCase>(
      () => _i75.ReportCallMisconductUseCase(gh<_i858.CallReportRepository>()),
    );
    gh.factory<_i217.HostWalletCubit>(
      () => _i217.HostWalletCubit(
        gh<_i933.GetHostWalletOverviewUseCase>(),
        gh<_i706.RequestWithdrawalUseCase>(),
      ),
    );
    gh.factory<_i199.ReferralCubit>(
      () => _i199.ReferralCubit(gh<_i141.VerifyReferralCode>()),
    );
    gh.factory<_i945.CallReportCubit>(
      () => _i945.CallReportCubit(
        reportCallMisconductUseCase: gh<_i75.ReportCallMisconductUseCase>(),
      ),
    );
    gh.factory<_i986.HostDashCubit>(
      () => _i986.HostDashCubit(
        gh<_i57.GetHostDashboardDataUseCase>(),
        gh<_i787.AuthRepository>(),
        gh<_i541.IPresenceSocketService>(),
        gh<_i833.TokenManager>(),
      ),
    );
    gh.factory<_i253.ProfileCubit>(
      () => _i253.ProfileCubit(
        gh<_i55.CreateUserProfile>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i1012.GetConversationMessagesUseCase>(
      () => _i1012.GetConversationMessagesUseCase(gh<_i562.ChatRepository>()),
    );
    gh.factory<_i142.GetConversationsUseCase>(
      () => _i142.GetConversationsUseCase(gh<_i562.ChatRepository>()),
    );
    gh.factory<_i253.GetPredefinedMessagesUseCase>(
      () => _i253.GetPredefinedMessagesUseCase(gh<_i562.ChatRepository>()),
    );
    gh.factory<_i711.MarkConversationReadUseCase>(
      () => _i711.MarkConversationReadUseCase(gh<_i562.ChatRepository>()),
    );
    gh.factory<_i309.MarkMessagesDeliveredUseCase>(
      () => _i309.MarkMessagesDeliveredUseCase(gh<_i562.ChatRepository>()),
    );
    gh.factory<_i26.SendMessageUseCase>(
      () => _i26.SendMessageUseCase(gh<_i562.ChatRepository>()),
    );
    gh.factory<_i57.AppStartCubit>(
      () => _i57.AppStartCubit(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i841.HostProfileCubit>(
      () => _i841.HostProfileCubit(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1032.GetHostApplicationStatusUseCase>(
      () => _i1032.GetHostApplicationStatusUseCase(
        gh<_i456.HostApplicationRepository>(),
      ),
    );
    gh.factory<_i211.SubmitHostApplicationUseCase>(
      () => _i211.SubmitHostApplicationUseCase(
        gh<_i456.HostApplicationRepository>(),
      ),
    );
    gh.factory<_i340.UploadImageUseCase>(
      () => _i340.UploadImageUseCase(gh<_i456.HostApplicationRepository>()),
    );
    gh.factory<_i663.GetHostsUseCase>(
      () => _i663.GetHostsUseCase(gh<_i136.HostRepository>()),
    );
    gh.factory<_i559.CallScreenCubit>(
      () => _i559.CallScreenCubit(
        gh<_i866.InitiateCallUseCase>(),
        gh<_i106.AcceptCallUseCase>(),
        gh<_i415.ActivateCallUseCase>(),
        gh<_i1018.EndCallUseCase>(),
        gh<_i692.CancelCallUseCase>(),
        gh<_i10.IAgoraService>(),
        gh<_i294.ICallRepository>(),
        gh<_i145.EnvConfig>(),
        gh<_i405.ICallPermissionService>(),
        gh<_i787.AuthRepository>(),
        gh<_i1015.IConnectivityService>(),
      ),
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
    gh.factory<_i891.ApplyForHostCubit>(
      () => _i891.ApplyForHostCubit(
        gh<_i211.SubmitHostApplicationUseCase>(),
        gh<_i340.UploadImageUseCase>(),
        gh<_i456.HostApplicationRepository>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i299.GetPerformanceAnalyticsUseCase>(
      () => _i299.GetPerformanceAnalyticsUseCase(
        gh<_i916.PerformanceAnalyticsRepository>(),
      ),
    );
    gh.factory<_i431.GetHostTargetsUseCase>(
      () => _i431.GetHostTargetsUseCase(gh<_i1003.HostTargetsRepository>()),
    );
    gh.factory<_i1050.WatchNewNotificationsUseCase>(
      () => _i1050.WatchNewNotificationsUseCase(
        gh<_i952.NotificationsRepository>(),
      ),
    );
    gh.factory<_i129.HomeCubit>(
      () => _i129.HomeCubit(
        gh<_i562.WatchHostPresenceUseCase>(),
        gh<_i725.ConnectHostPresenceUseCase>(),
        gh<_i369.DisconnectHostPresenceUseCase>(),
        gh<_i663.GetHostsUseCase>(),
        gh<_i787.AuthRepository>(),
        gh<_i833.TokenManager>(),
        gh<_i381.GetFavoriteHostsUseCase>(),
        gh<_i381.AddFavoriteUseCase>(),
        gh<_i193.RemoveFavoriteUseCase>(),
      ),
    );
    gh.factory<_i779.AcceptHostTermsUseCase>(
      () => _i779.AcceptHostTermsUseCase(gh<_i456.HostApplicationRepository>()),
    );
    gh.factory<_i200.CheckHostApplicationEligibilityUseCase>(
      () => _i200.CheckHostApplicationEligibilityUseCase(
        gh<_i456.HostApplicationRepository>(),
      ),
    );
    gh.factory<_i718.ApplyForLeaveCubit>(
      () => _i718.ApplyForLeaveCubit(
        applyForLeaveUseCase: gh<_i877.ApplyForLeaveUseCase>(),
        getAvailableDaysUseCase: gh<_i75.GetAvailableDaysUseCase>(),
        getLeaveHistoryUseCase: gh<_i438.GetLeaveHistoryUseCase>(),
      ),
    );
    gh.factory<_i454.HostFavoriteCubit>(
      () => _i454.HostFavoriteCubit(
        gh<_i381.AddFavoriteUseCase>(),
        gh<_i193.RemoveFavoriteUseCase>(),
      ),
    );
    gh.factory<_i32.UploadProfileImageUseCase>(
      () => _i32.UploadProfileImageUseCase(gh<_i418.ProfileRepository>()),
    );
    gh.factory<_i285.WalletCubit>(
      () => _i285.WalletCubit(
        initializeWalletUseCase: gh<_i601.InitializeWalletUseCase>(),
        getWalletBalanceUseCase: gh<_i98.GetWalletBalanceUseCase>(),
        createOrderUseCase: gh<_i961.CreateOrderUseCase>(),
        verifyPaymentUseCase: gh<_i821.VerifyPaymentUseCase>(),
        getPlansUseCase: gh<_i284.GetPlansUseCase>(),
        authRepository: gh<_i787.AuthRepository>(),
        razorpayService: gh<_i976.RazorpayService>(),
      ),
    );
    gh.factory<_i276.UserRechargeHistoryCubit>(
      () => _i276.UserRechargeHistoryCubit(
        gh<_i481.GetRechargeHistoryUseCase>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i633.HostProfileEditCubit>(
      () => _i633.HostProfileEditCubit(
        getProfileUseCase: gh<_i13.GetHostProfileUseCase>(),
        updateProfileUseCase: gh<_i502.UpdateHostProfileUseCase>(),
        uploadProfileImageUseCase: gh<_i32.UploadProfileImageUseCase>(),
        authRepository: gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i746.ProfileInfoCubit>(
      () => _i746.ProfileInfoCubit(
        gh<_i787.AuthRepository>(),
        gh<_i200.CheckHostApplicationEligibilityUseCase>(),
        gh<_i173.NavigationService>(),
      ),
    );
    gh.factory<_i497.ReferralStatusCubit>(
      () => _i497.ReferralStatusCubit(
        gh<_i790.GetReferralStatusUseCase>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i834.ConversationsCubit>(
      () => _i834.ConversationsCubit(
        gh<_i142.GetConversationsUseCase>(),
        gh<_i852.IAuthLocalDataSource>(),
        gh<_i224.WatchNewMessagesUseCase>(),
      ),
    );
    gh.factory<_i117.LogoutCubit>(
      () => _i117.LogoutCubit(gh<_i48.LogoutUseCase>()),
    );
    gh.factory<_i1021.GetCallStatisticsUseCase>(
      () => _i1021.GetCallStatisticsUseCase(gh<_i271.CallLogRepository>()),
    );
    gh.factory<_i148.GetHostCallLogsUseCase>(
      () => _i148.GetHostCallLogsUseCase(gh<_i271.CallLogRepository>()),
    );
    gh.factory<_i67.GetUserCallLogsUseCase>(
      () => _i67.GetUserCallLogsUseCase(gh<_i271.CallLogRepository>()),
    );
    gh.factory<_i864.NewMessagePickerCubit>(
      () => _i864.NewMessagePickerCubit(gh<_i148.GetHostCallLogsUseCase>()),
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
    gh.factory<_i610.CallLogCubit>(
      () => _i610.CallLogCubit(
        getUserCallLogsUseCase: gh<_i67.GetUserCallLogsUseCase>(),
        getHostCallLogsUseCase: gh<_i148.GetHostCallLogsUseCase>(),
      ),
    );
    gh.factory<_i1036.UserProfileEditCubit>(
      () => _i1036.UserProfileEditCubit(
        gh<_i599.UpdateUserProfile>(),
        gh<_i787.AuthRepository>(),
        gh<_i32.UploadProfileImageUseCase>(),
      ),
    );
    gh.factory<_i821.HostApplicationStatusCubit>(
      () => _i821.HostApplicationStatusCubit(
        gh<_i1032.GetHostApplicationStatusUseCase>(),
      ),
    );
    gh.factory<_i322.HostAnalyticsCubit>(
      () => _i322.HostAnalyticsCubit(
        getPerformanceAnalyticsUseCase:
            gh<_i299.GetPerformanceAnalyticsUseCase>(),
        getCallStatisticsUseCase: gh<_i1021.GetCallStatisticsUseCase>(),
        getHostTargetsUseCase: gh<_i431.GetHostTargetsUseCase>(),
      ),
    );
    gh.factory<_i611.NotificationsCubit>(
      () => _i611.NotificationsCubit(
        gh<_i791.GetNotificationsUseCase>(),
        gh<_i300.GetUnreadCountUseCase>(),
        gh<_i1029.MarkNotificationReadUseCase>(),
        gh<_i279.MarkAllNotificationsReadUseCase>(),
        gh<_i1050.WatchNewNotificationsUseCase>(),
      ),
    );
    gh.factory<_i62.ProfileImageCubit>(
      () => _i62.ProfileImageCubit(
        uploadProfileImageUseCase: gh<_i32.UploadProfileImageUseCase>(),
      ),
    );
    gh.factory<_i575.HostCallLogCubit>(
      () => _i575.HostCallLogCubit(
        getHostCallLogsUseCase: gh<_i148.GetHostCallLogsUseCase>(),
        blockUserUseCase: gh<_i154.BlockUserUseCase>(),
        unblockUserUseCase: gh<_i415.UnblockUserUseCase>(),
      ),
    );
    return this;
  }
}

class _$StorageModule extends _i371.StorageModule {}

class _$DioModule extends _i651.DioModule {}
