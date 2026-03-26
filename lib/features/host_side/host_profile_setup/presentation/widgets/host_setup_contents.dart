import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/dob_picker_bottom_sheet.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_state.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/widgets/host_profile_avatar.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/widgets/preferred_categories.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_logo.dart';

class HostSetupContents extends StatelessWidget {
  const HostSetupContents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HostProfileSetupCubit, HostProfileSetupState>(
      listener: (context, state) {
        if (state.status == HostProfileSetupStatus.success) {
          // Navigate to next screen or show success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Setup Successful!')),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<HostProfileSetupCubit>();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              const ProfileLogo(),
              SizedBox(height: 30.h),
              Text(
                AppTexts.setupProfile,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 32.h),
              const HostProfileAvatar(),
              SizedBox(height: 32.h),

              ProfileField(
                label: AppTexts.enteryourName,
                hintText: AppTexts.enterName,
                labelColor: AppColors.primaryColor,
                initialValue: state.name,
                onChanged: cubit.nameChanged,
                errorText: state.showErrors && state.name.isEmpty ? 'Name is required' : null,
                suffixIcon: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Icon(
                    Icons.check_circle,
                    color: state.name.isNotEmpty ? AppColors.green : AppColors.transparent,
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              ProfileField(
                key: ValueKey(state.dob),
                label: AppTexts.dateOfBirthText,
                hintText: AppTexts.dobFormat,
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

              const PreferredCategories(),
              if (state.showErrors && state.selectedCategories.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    'Select at least one category',
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
              SizedBox(height: 48.h),

              // Submit Button
              PrimaryButton(
                text: state.status == HostProfileSetupStatus.submitting
                    ? 'SUBMITTING...'
                    : AppTexts.submit.toUpperCase(),
                onPressed: state.status == HostProfileSetupStatus.submitting
                    ? null
                    : () => cubit.submit(),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        );
      },
    );
  }
}
