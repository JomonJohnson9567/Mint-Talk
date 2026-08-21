import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/cubit/user_recharge_history_cubit.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/user_recharge_history_contents.dart';

class UserRechargeHistory extends StatelessWidget {
  const UserRechargeHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UserRechargeHistoryCubit>()..loadHistory(),
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
