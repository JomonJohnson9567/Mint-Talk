import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';
import 'apply_form_field.dart';

class ApplyNameInput extends StatelessWidget {
  const ApplyNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (previous, current) =>
          previous.fieldErrors['name'] != current.fieldErrors['name'],
      builder: (_, state) => ApplyFormField(
        key: const Key('apply_name_input'),
        label: AppTexts.fullNameLabel,
        hintText: AppTexts.fullNameHint,
        prefixIcon: Icons.person_outline_rounded,
        initialValue: state.name,
        errorText: state.fieldErrors['name'],
        onChanged: cubit.nameChanged,
        textCapitalization: TextCapitalization.words,
      ),
    );
  }
}
