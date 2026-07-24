import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/network/api_client.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/data/datasources/recharge_history_remote_datasource.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/data/repositories/recharge_history_repository_impl.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/usecases/get_recharge_history_usecase.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_cubit.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/user_recharge_history_contents.dart';

class UserRechargeHistory extends StatelessWidget {
  const UserRechargeHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = getIt<ApiClient>();
    final authLocalDataSource = getIt<AuthLocalDataSource>();
    final remoteDataSource = RechargeHistoryRemoteDataSourceImpl(apiClient);
    final repository = RechargeHistoryRepositoryImpl(remoteDataSource);
    final useCase = GetRechargeHistoryUseCase(repository);

    return BlocProvider(
      create: (_) => UserRechargeHistoryCubit(useCase, authLocalDataSource)
        ..loadHistory(),
      child: const Scaffold(
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(
          title: 'Recharge History',
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(child: UserRechargeHistoryContents()),
      ),
    );
  }
}
