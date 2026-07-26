import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

class ApplyBioInput extends StatelessWidget {
  const ApplyBioInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (previous, current) =>
          previous.fieldErrors['bio'] != current.fieldErrors['bio'],
      builder: (_, state) => ProfileField(
        key: const Key('apply_bio_input'),
        label: 'BIO',
        hintText: 'Tell us a bit about yourself (min 10 characters)',
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
