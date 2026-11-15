import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_cubit.dart';
import 'package:mint_talk/features/user_side/wallet/presentation/cubit/wallet_state.dart';
import 'package:mint_talk/features/user_side/wallet/domain/entities/recharge_plan_entity.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_balance_card.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_continue_bar.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_hero.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_plan_grid.dart';
import 'package:mint_talk/features/user_side/recharge_plans/presentation/widgets/recharge_plans_skeleton.dart';

class ScreenContents extends StatefulWidget {
  const ScreenContents({super.key, required this.contentWidth});

  final double contentWidth;

  @override
  State<ScreenContents> createState() => _ScreenContentsState();
}

class _ScreenContentsState extends State<ScreenContents> {
  /// Selection is ephemeral screen state — it only decides which card wears
  /// its tier theme and what the Continue bar opens.
  String? _selectedPlanId;

  /// Kept after deselecting so the Continue bar can slide out with content.
  RechargePlanEntity? _lastSelectedPlan;

  @override
  void initState() {
    super.initState();
    // Fetch once per visit — not from build, which reruns on every rebuild.
    context.read<WalletCubit>().fetchPlans();
  }

  void _onSelect(RechargePlanEntity plan) {
    setState(() {
      _selectedPlanId = _selectedPlanId == plan.id ? null : plan.id;
      _lastSelectedPlan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (previous, current) => previous.plans != current.plans,
      builder: (context, state) {
        // A refresh can drop the selected plan; treat it as deselected.
        final selectedPlan =
            state.plans.where((plan) => plan.id == _selectedPlanId).firstOrNull;
        final barPlan = selectedPlan ??
            (state.plans.contains(_lastSelectedPlan) ? _lastSelectedPlan : null);

        return Stack(
          children: [
            _buildScroll(state, selectedPlan),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: RechargeContinueBar(
                plan: barPlan,
                visible: selectedPlan != null,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScroll(WalletState state, RechargePlanEntity? selectedPlan) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 720 ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding.cw,
            4.cw,
            horizontalPadding.cw,
            0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.contentWidth),
              child: AnimatedPadding(
                duration: reduceMotion
                    ? Duration.zero
                    : RechargeContinueBar.slideDuration,
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(
                  bottom: 24.cw +
                      (selectedPlan != null
                          ? RechargeContinueBar.reservedHeight
                          : 0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const RechargeHero(),
                    SizedBox(height: 14.cw),
                    const RechargeBalanceCard(),
                    SizedBox(height: 22.cw),
                    Text(
                      AppTexts.chooseYourPack,
                      style: GoogleFonts.nunito(
                        fontSize: 20.csp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.plumDeep,
                      ),
                    ),
                    SizedBox(height: 12.cw),
                    // Plans from an earlier visit stay on screen while they
                    // refresh; the skeleton only covers a cold load.
                    if (state.plans.isEmpty)
                      const RechargePlansSkeleton()
                    else
                      RechargePlanGrid(
                        plans: state.plans,
                        selectedPlanId: selectedPlan?.id,
                        onSelect: _onSelect,
                      ),
                    SizedBox(height: 18.cw),
                    const _ReferralStatusPromptCard(),
                    SizedBox(height: 18.cw),
                    const _SecurePaymentsFooter(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReferralStatusPromptCard extends StatelessWidget {
  const _ReferralStatusPromptCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.referralStatusScreen);
      },
      borderRadius: BorderRadius.circular(18.cw),
      child: Container(
        padding: EdgeInsets.all(14.cw),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(18.cw),
          border: Border.all(
            color: AppColors.primaryColor.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.plumDeep.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46.cw,
              height: 46.cw,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.primaryColor,
                size: 22.csp,
              ),
            ),
            SizedBox(width: 12.cw),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.referralStatus,
                    style: TextStyle(
                      fontSize: 14.5.csp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.plumDeep,
                    ),
                  ),
                  SizedBox(height: 3.cw),
                  Text(
                    'Track referral rewards and share your invite code from one place.',
                    style: TextStyle(
                      fontSize: 12.csp,
                      color: AppColors.plumMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.cw),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15.csp,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurePaymentsFooter extends StatelessWidget {
  const _SecurePaymentsFooter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_rounded, size: 16.csp, color: AppColors.plumHint),
        SizedBox(width: 6.cw),
        Text(
          AppTexts.securePayments,
          style: TextStyle(
            fontSize: 12.5.csp,
            fontWeight: FontWeight.w600,
            color: AppColors.plumHint,
          ),
        ),
      ],
    );
  }
}
