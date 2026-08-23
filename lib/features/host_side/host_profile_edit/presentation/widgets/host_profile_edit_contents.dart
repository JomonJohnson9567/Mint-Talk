import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/dob_picker_bottom_sheet.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import '../cubit/host_profile_edit_cubit.dart';
import '../cubit/host_profile_edit_state.dart';
import 'host_profile_edit_avatar.dart';
import 'host_profile_edit_categories.dart';

class HostProfileEditContents extends StatelessWidget {
  const HostProfileEditContents({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HostProfileEditCubit>();

    return BlocBuilder<HostProfileEditCubit, HostProfileEditState>(
      builder: (context, state) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HostProfileEditAvatar(
                avatarAsset: state.avatarAsset,
                onAvatarChanged: cubit.avatarChanged,
              ),
              SizedBox(height: 24.h),
              _HostProfileFormFields(state: state, cubit: cubit),
              SizedBox(height: 24.h),
              const HostProfileEditCategories(),
              if (state.showErrors && state.selectedCategories.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    'Select at least one category',
                    style: TextStyle(color: AppColors.red, fontSize: 12.sp),
                  ),
                ),
              SizedBox(height: 40.h),
              PrimaryButton(
                text: 'SAVE CHANGES',
                isLoading: state.status == HostProfileEditStatus.saving,
                onPressed: state.status == HostProfileEditStatus.saving
                    ? null
                    : cubit.submit,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

class _HostProfileFormFields extends StatelessWidget {
  final HostProfileEditState state;
  final HostProfileEditCubit cubit;

  const _HostProfileFormFields({
    required this.state,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Name
        ProfileField(
          key: ValueKey('name_${state.name}'),
          label: 'FULL NAME',
          hintText: 'Enter your name',
          labelColor: AppColors.primaryColor,
          initialValue: state.name,
          onChanged: cubit.nameChanged,
          errorText: state.showErrors && state.name.trim().isEmpty
              ? 'Name is required'
              : null,
        ),
        SizedBox(height: 20.h),

        // Mobile Number (Read-only)
        ProfileField(
          key: ValueKey('phone_${state.phone}'),
          label: 'MOBILE NUMBER (READ ONLY)',
          hintText: 'Mobile number',
          labelColor: AppColors.primaryColor.withAlpha(153),
          initialValue: state.phone,
          readOnly: true,
          suffixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.textGrey.withAlpha(128),
            size: 18.sp,
          ),
        ),
        SizedBox(height: 20.h),

        // ID Number (Read-only)
        ProfileField(
          key: ValueKey('id_${state.idNumber}'),
          label: 'ID NUMBER (READ ONLY)',
          hintText: 'ID number',
          labelColor: AppColors.primaryColor.withAlpha(153),
          initialValue: state.idNumber,
          readOnly: true,
          suffixIcon: Icon(
            Icons.lock_outline,
            color: AppColors.textGrey.withAlpha(128),
            size: 18.sp,
          ),
        ),
        SizedBox(height: 20.h),

        // Date of Birth
        ProfileField(
          key: ValueKey('dob_${state.dob}'),
          label: 'DATE OF BIRTH',
          hintText: 'DD/MM/YYYY',
          labelColor: AppColors.primaryColor,
          initialValue: state.dob,
          readOnly: true,
          errorText: state.showErrors && state.dob.isEmpty
              ? 'DOB is required'
              : null,
          suffixIcon: Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textGrey,
            ),
          ),
          onTap: () {
            DobPickerBottomSheet.show(
              context: context,
              currentDob: state.dob,
              onDateSelected: cubit.dobChanged,
            );
          },
        ),
      ],
    );
  }
}
