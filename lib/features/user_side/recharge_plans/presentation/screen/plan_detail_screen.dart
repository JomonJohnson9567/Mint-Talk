import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/navigations/navigation_service.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/cubit/plan_detail_cubit.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/cubit/plan_detail_state.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/plan_benefits_card.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/plan_detail_failure.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/plan_detail_hero.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/plan_detail_section_card.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/plan_pay_bar.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail/plan_payment_summary.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/plan_detail_skeleton.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/pages/recharge_success_screen.dart';

class PlanDetailArgs {
  final String planId;

  /// The plan as already shown in the list. When given, the screen renders
  /// it immediately instead of fetching by [planId].
  final RechargePlanEntity? plan;
  final bool isPopular;

  PlanDetailArgs({required this.planId, this.plan, this.isPopular = false});
}

class PlanDetailScreen extends StatelessWidget {
  final PlanDetailArgs args;

  const PlanDetailScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<PlanDetailCubit>()..loadPlan(args.planId, initial: args.plan),
      child: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state.status == WalletStatus.paymentSuccess) {
            final plan = context.read<PlanDetailCubit>().currentPlan;

            getIt<NavigationService>().replaceWith(
              AppRoutes.rechargeSuccess,
              arguments: RechargeSuccessArgs(
                addedPoints: plan?.coinAmount ?? 0,
                totalBalance: state.balance,
              ),
            );
          } else if (state.status == WalletStatus.error) {
            _showSnackBar(context, state.errorMessage ?? 'An error occurred');
          } else if (state.status == WalletStatus.paymentFailure) {
            _showSnackBar(context, state.errorMessage ?? 'Payment failed');
          }
        },
        child: BlocBuilder<PlanDetailCubit, PlanDetailState>(
          builder: (context, state) {
            final plan = state.plan;

            return Scaffold(
              backgroundColor: AppColors.rechargeBackground,
              appBar: const CustomAppBar(
                title: AppTexts.planDetails,
                automaticallyImplyLeading: true,
                foregroundColor: AppColors.plumDeep,
              ),
              bottomNavigationBar: plan == null ? null : PlanPayBar(plan: plan),
              body: SafeArea(bottom: false, child: _buildBody(context, state)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PlanDetailState state) {
    final plan = state.plan;

    if (plan == null) {
      if (state.status == PlanDetailStatus.failure) {
        return PlanDetailFailure(
          message: state.errorMessage ?? 'Failed to load plan details',
          onRetry: () => context.read<PlanDetailCubit>().loadPlan(args.planId),
        );
      }
      return const PlanDetailSkeleton();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.cw, 8.cw, 16.cw, 24.cw),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlanDetailHero(plan: plan, isPopular: args.isPopular),
              SizedBox(height: 22.cw),
              const PlanDetailSectionTitle(AppTexts.whatYouGet),
              SizedBox(height: 12.cw),
              const PlanBenefitsCard(),
              SizedBox(height: 22.cw),
              const PlanDetailSectionTitle(AppTexts.paymentSummary),
              SizedBox(height: 12.cw),
              PlanPaymentSummary(plan: plan),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
