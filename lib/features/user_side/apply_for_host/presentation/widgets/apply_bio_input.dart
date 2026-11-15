import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';
import 'apply_form_field.dart';

class ApplyBioInput extends StatelessWidget {
  const ApplyBioInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (previous, current) =>
          previous.fieldErrors['bio'] != current.fieldErrors['bio'],
      builder: (_, state) => ApplyFormField(
        key: const Key('apply_bio_input'),
        label: AppTexts.bioLabel,
        hintText: AppTexts.bioHint,
        prefixIcon: Icons.edit_note_rounded,
        initialValue: state.bio,
        errorText: state.fieldErrors['bio'],
        onChanged: cubit.bioChanged,
        maxLines: 4,
        minLines: 3,
        maxLength: 200,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}
