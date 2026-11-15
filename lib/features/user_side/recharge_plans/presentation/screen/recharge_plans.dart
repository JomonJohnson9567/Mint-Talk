import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/pages/recharge_success_screen.dart';
import '../widgets/screen_contents.dart';

class RechargePlans extends StatelessWidget {
  const RechargePlans({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCubit, WalletState>(

      listenWhen: (previous, current) => previous.status != current.status,
      listener: _onWalletStatus,
      child: Scaffold(
        backgroundColor: AppColors.rechargeBackground,
        appBar: CustomAppBar(
          title: AppTexts.rechargePlans,
          automaticallyImplyLeading: true,
          foregroundColor: AppColors.plumDeep,
          actions: [
            IconButton(
              tooltip: 'Recharge history',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.userRechargeHistory);
              },
              icon: const Icon(Icons.history_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const ScreenContents(contentWidth: 760.0),
              // Blocks taps and shows progress while the order is created
              // and while the payment is verified.
              BlocBuilder<WalletCubit, WalletState>(
                buildWhen: (previous, current) =>
                    previous.status != current.status,
                builder: (context, state) {
                  if (state.status != WalletStatus.paymentProcessing) {
                    return const SizedBox.shrink();
                  }
                  return Positioned.fill(
                    child: ColoredBox(
                      color: AppColors.plumDeep.withValues(alpha: 0.12),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onWalletStatus(BuildContext context, WalletState state) {
    // Only react while this screen is on top, so a recharge started from
    // another screen isn't handled twice.
    if (ModalRoute.of(context)?.isCurrent != true) return;

    switch (state.status) {
      case WalletStatus.paymentSuccess:
        final planId = context.read<WalletCubit>().pendingPlanId;
        final plan = state.plans.where((p) => p.id == planId).firstOrNull;
        getIt<NavigationService>().navigateTo(
          AppRoutes.rechargeSuccess,
          arguments: RechargeSuccessArgs(
            addedPoints: plan?.coinAmount ?? 0,
            totalBalance: state.balance,
          ),
        );
      case WalletStatus.paymentFailure:
        _showSnackBar(context, state.errorMessage ?? 'Payment failed');
      default:
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
