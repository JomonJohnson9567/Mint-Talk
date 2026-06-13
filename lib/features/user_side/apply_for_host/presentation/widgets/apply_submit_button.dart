import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

class ApplySubmitButton extends StatelessWidget {
  const ApplySubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (p, c) => p.status != c.status,
      builder: (context, state) {
        final isSubmitting = state.status == ApplyForHostStatus.submitting;
        return PrimaryButton(
          text: isSubmitting ? 'SUBMITTING...' : 'SUBMIT APPLICATION',
          isLoading: isSubmitting,
          onPressed: !isSubmitting ? cubit.submit : null,
        );
      },
    );
  }
}
