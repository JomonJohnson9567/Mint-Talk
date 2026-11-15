import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/back_title_header.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';
import '../widgets/apply_bio_input.dart';
import '../widgets/apply_dob_input.dart';
import '../widgets/apply_for_host_skeleton.dart';
import '../widgets/apply_host_hero_card.dart';
import '../widgets/apply_name_input.dart';
import '../widgets/apply_referral_input.dart';
import '../widgets/apply_section.dart';
import '../widgets/apply_selfie_upload.dart';
import '../widgets/apply_submit_button.dart';
import '../widgets/apply_success_dialog.dart';

class ApplyForHost extends StatelessWidget {
  const ApplyForHost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackground,
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ApplyForHostCubit, ApplyForHostState>(
          listenWhen: (p, c) => p.status != c.status,
          listener: (context, state) {
            if (state.status == ApplyForHostStatus.success) {
              ApplySuccessDialog.show(context);
            } else if (state.status == ApplyForHostStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.errorMessage ?? AppTexts.submissionFailed,
                  ),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          buildWhen: (p, c) =>
              (p.status == ApplyForHostStatus.loading) !=
              (c.status == ApplyForHostStatus.loading),
          builder: (context, state) {
            if (state.status == ApplyForHostStatus.loading) {
              return const ApplyForHostSkeleton();
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16.cw, 12.cw, 16.cw, 24.cw),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BackTitleHeader(
                          title: AppTexts.applyForHost,
                          subtitle: AppTexts.applyForHostSubtitle,
                        ),
                        SizedBox(height: 18.cw),
                        const ApplyHostHeroCard(),
                        SizedBox(height: 22.cw),
                        const ApplySectionTitle(AppTexts.personalDetails),
                        SizedBox(height: 10.cw),
                        ApplySectionCard(
                          child: Column(
                            children: [
                              const ApplyNameInput(),
                              SizedBox(height: 16.cw),
                              const ApplyDobInput(),
                              SizedBox(height: 16.cw),
                              const ApplyReferralInput(),
                              SizedBox(height: 16.cw),
                              // const ApplyBioInput(),
                            ],
                          ),
                        ),
                        SizedBox(height: 22.cw),
                        const ApplySectionTitle(AppTexts.verifyItsYou),
                        SizedBox(height: 10.cw),
                        const ApplySectionCard(child: ApplySelfieUpload()),
                      ],
                    ),
                  ),
                ),
                const ApplySubmitButton(),
              ],
            );
          },
        ),
      ),
    );
  }
}
