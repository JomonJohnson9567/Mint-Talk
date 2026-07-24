import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/cubit/referral_status_cubit.dart';
import 'package:mint_talk/features/user_side/user_referral_status/presentation/widgets/referral_status_contents.dart';

class ReferralStatusScreen extends StatelessWidget {
  const ReferralStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReferralStatusCubit>()..loadStatus(),
      child: const Scaffold(
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(
          title: 'Referral Status',
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(child: ReferralStatusContents()),
      ),
    );
  }
}
