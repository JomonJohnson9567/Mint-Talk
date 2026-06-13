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
      buildWhen: (p, c) => p.bio != c.bio || p.fieldErrors['bio'] != c.fieldErrors['bio'],
      builder: (context, state) {
        return ProfileField(
          label: 'HOST BIO',
          hintText: 'Enter host bio (min 10 characters)',
          initialValue: state.bio,
          errorText: state.fieldErrors['bio'],
          onChanged: cubit.bioChanged,
        );
      },
    );
  }
}
