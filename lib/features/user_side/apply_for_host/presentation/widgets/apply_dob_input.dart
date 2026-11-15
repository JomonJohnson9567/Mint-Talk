import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';
import 'apply_form_field.dart';

/// Date of birth is prefilled from the user's profile and cannot be edited
/// on the host application.
class ApplyDobInput extends StatelessWidget {
  const ApplyDobInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (p, c) =>
          p.dob != c.dob || p.fieldErrors['dob'] != c.fieldErrors['dob'],
      builder: (context, state) {
        return ApplyFormField(
          key: ValueKey(state.dob),
          label: AppTexts.dateOfBirthText,
          hintText: AppTexts.dobHint,
          prefixIcon: Icons.cake_outlined,
          suffixIcon: Icon(
            Icons.lock_outline_rounded,
            size: 20.csp,
            color: AppColors.plumMuted,
          ),
          enabled: false,
          initialValue: state.dob,
          errorText: state.fieldErrors['dob'],
        );
      },
    );
  }
}
