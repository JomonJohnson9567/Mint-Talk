import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/widgets/dob_picker_bottom_sheet.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import '../cubit/host_profile_edit_cubit.dart';
import '../cubit/host_profile_edit_state.dart';
import '../widgets/host_profile_edit_avatar.dart';
import '../widgets/host_profile_edit_categories.dart';

class HostProfileEdit extends StatelessWidget {
  const HostProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Edit Profile',
        automaticallyImplyLeading: true,
      ),
      body: BlocConsumer<HostProfileEditCubit, HostProfileEditState>(
        listener: (context, state) {
          if (state.status == HostProfileEditStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile Updated Successfully!'),
                backgroundColor: AppColors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state.status == HostProfileEditStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Failed to update profile'),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == HostProfileEditStatus.loading ||
              state.status == HostProfileEditStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }

          final cubit = context.read<HostProfileEditCubit>();

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HostProfileEditAvatar(
                  avatarAsset: state.avatarAsset,
                  onAvatarChanged: cubit.avatarChanged,
                ),
                SizedBox(height: 24.h),
                
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

                // Email Address
                ProfileField(
                  key: ValueKey('email_${state.email}'),
                  label: 'EMAIL ADDRESS',
                  hintText: 'Enter your email',
                  labelColor: AppColors.primaryColor,
                  initialValue: state.email,
                  onChanged: cubit.emailChanged,
                  keyboardType: TextInputType.emailAddress,
                  errorText: state.showErrors && state.email.trim().isEmpty
                      ? 'Email is required'
                      : (state.showErrors && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(state.email.trim())
                          ? 'Enter a valid email address'
                          : null),
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
                  errorText: state.showErrors && state.dob.isEmpty ? 'DOB is required' : null,
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
                SizedBox(height: 24.h),

                // Preferred Categories selector
                const HostProfileEditCategories(),
                if (state.showErrors && state.selectedCategories.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Select at least one category',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                SizedBox(height: 40.h),

                // Submit Save Button
                PrimaryButton(
                  text: 'SAVE CHANGES',
                  isLoading: state.status == HostProfileEditStatus.saving,
                  onPressed: state.status == HostProfileEditStatus.saving ? null : cubit.submit,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          );
        },
      ),
    );
  }
}