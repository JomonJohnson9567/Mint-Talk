import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import '../widgets/wallet_contents.dart';

class HostWallet extends StatelessWidget {
  const HostWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HostWalletCubit>()..initialize(),
      child: const Scaffold(
        appBar: CustomAppBar(
          title: AppTexts.hostWallet,
          automaticallyImplyLeading: true,
          foregroundColor: AppColors.plumDeep,
        ),
        backgroundColor: AppColors.homeBackground,
        body: WalletContents(),
      ),
    );
  }
}
