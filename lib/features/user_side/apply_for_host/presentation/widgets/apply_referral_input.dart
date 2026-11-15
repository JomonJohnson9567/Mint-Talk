import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/referral_cubit.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/cubit/referral_state.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';
import 'apply_form_field.dart';

/// Optional referral code, verified live (debounced) via [ReferralCubit] —
/// the same check used on profile setup. The result is mirrored into
/// [ApplyForHostCubit] so submit can block on an invalid / pending code.
class ApplyReferralInput extends StatelessWidget {
  const ApplyReferralInput({super.key});

  static ReferralCheck _toCheck(ReferralState s) => switch (s) {
    ReferralLoading() => ReferralCheck.checking,
    ReferralValid() => ReferralCheck.valid,
    ReferralInvalid() => ReferralCheck.invalid,
    _ => ReferralCheck.idle,
  };

  @override
  Widget build(BuildContext context) {
    final applyCubit = context.read<ApplyForHostCubit>();
    final referralCubit = context.read<ReferralCubit>();

    return BlocConsumer<ReferralCubit, ReferralState>(
      listener: (_, state) => applyCubit.referralCheckChanged(_toCheck(state)),
      builder: (context, referralState) {
        Widget? suffix;
        String? apiError;

        if (referralState is ReferralLoading) {
          suffix = SizedBox(
            width: 20.cw,
            height: 20.cw,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          );
        } else if (referralState is ReferralValid) {
          suffix = Icon(AppIcons.checkCircle, color: AppColors.onlineIndicator);
        } else if (referralState is ReferralInvalid) {
          suffix = Icon(AppIcons.error, color: Colors.red.shade700);
          apiError = referralState.message;
        }

        return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
          buildWhen: (p, c) =>
              p.fieldErrors['referralCode'] != c.fieldErrors['referralCode'],
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApplyFormField(
                  key: const Key('apply_referral_input'),
                  label: AppTexts.referralCodeOptional,
                  hintText: AppTexts.enterCode,
                  prefixIcon: Icons.card_giftcard_rounded,
                  initialValue: state.referralCode,
                  maxLength: 15,
                  textCapitalization: TextCapitalization.characters,
                  suffixIcon: suffix == null
                      ? null
                      : Padding(padding: EdgeInsets.all(12.cw), child: suffix),
                  errorText: state.fieldErrors['referralCode'] ?? apiError,
                  onChanged: (value) {
                    applyCubit.referralCodeChanged(value);
                    referralCubit.onReferralCodeChanged(
                      value.trim().toUpperCase(),
                    );
                  },
                ),
                if (referralState is ReferralValid)
                  Padding(
                    padding: EdgeInsets.only(left: 16.cw),
                    child: Text(
                      referralState.message,
                      style: TextStyle(
                        color: AppColors.onlineIndicator,
                        fontSize: 12.csp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
