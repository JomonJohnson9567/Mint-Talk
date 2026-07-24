import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

class ApplyNameInput extends StatelessWidget {
  const ApplyNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.fieldErrors['name'] != current.fieldErrors['name'],
      builder: (_, state) => ProfileField(
        key: ValueKey('name_${state.name}'),
        label: 'FULL NAME',
        hintText: 'Enter your full name',
        initialValue: state.name,
        errorText: state.fieldErrors['name'],
        onChanged: cubit.nameChanged,
        textCapitalization: TextCapitalization.words,
      ),
    );
  }
}
