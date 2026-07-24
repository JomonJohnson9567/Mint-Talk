import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_icons.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/dob_picker_bottom_sheet.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

class ApplyDobInput extends StatelessWidget {
  const ApplyDobInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (p, c) =>
          p.dob != c.dob || p.fieldErrors['dob'] != c.fieldErrors['dob'],
      builder: (context, state) {
        return ProfileField(
          key: ValueKey(state.dob),
          label: 'DATE OF BIRTH',
          hintText: 'DD/MM/YYYY',
          suffixIcon: Icon(AppIcons.calendar, color: AppColors.textGrey),
          readOnly: true,
          initialValue: state.dob,
          errorText: state.fieldErrors['dob'],
          onTap: () {
            DobPickerBottomSheet.show(
              context: context,
              currentDob: state.dob,
              onDateSelected: cubit.dobChanged,
            );
          },
        );
      },
    );
  }
}
