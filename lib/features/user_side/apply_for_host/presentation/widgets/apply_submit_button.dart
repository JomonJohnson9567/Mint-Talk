import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

/// Sticky bottom bar with the submit button. Sits below the scroll view (not
/// in `bottomNavigationBar`) so it rides above the keyboard.
class ApplySubmitButton extends StatelessWidget {
  const ApplySubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.homeBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 12.cw),
          child: BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
            buildWhen: (p, c) => p.status != c.status,
            builder: (context, state) {
              final isSubmitting =
                  state.status == ApplyForHostStatus.submitting;
              return PrimaryButton(
                text: AppTexts.submitApplication,
                height: 52.cw,
                isLoading: isSubmitting,
                disabledBackgroundColor: AppColors.primaryColor.withValues(
                  alpha: 0.6,
                ),
                disabledForegroundColor: AppColors.white,
                textStyle: GoogleFonts.nunito(
                  fontSize: 16.csp,
                  fontWeight: FontWeight.w800,
                ),
                onPressed: isSubmitting
                    ? null
                    : () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        cubit.submit();
                      },
              );
            },
          ),
        ),
      ),
    );
  }
}
