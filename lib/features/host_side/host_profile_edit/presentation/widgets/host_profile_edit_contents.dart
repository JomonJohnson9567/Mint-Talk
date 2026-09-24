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
        _NameField(
          name: state.name,
          showError: state.showErrors,
          onChanged: cubit.nameChanged,
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

/// Owns the name field's [TextEditingController] itself instead of relying
/// on [ProfileField]'s `initialValue`, which only ever seeds the field on
/// its very first build. `initialValue` alone can't reflect the name
/// arriving later from [HostProfileEditCubit.loadProfile]'s async fetch, so
/// this used to be keyed off `state.name` to force a remount whenever it
/// changed — which also remounted (and stole focus from) the field on
/// every single keystroke, since `onChanged` emits a new `state.name` on
/// every character. Syncing the controller in [didUpdateWidget] instead
/// picks up the async-loaded name without ever touching focus while typing.
class _NameField extends StatefulWidget {
  final String name;
  final bool showError;
  final ValueChanged<String> onChanged;

  const _NameField({
    required this.name,
    required this.showError,
    required this.onChanged,
  });

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void didUpdateWidget(covariant _NameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only external changes (the async profile load) land here — typing
    // routes through onChanged -> cubit -> this same widget.name, so it
    // already matches _controller.text by the time this runs and this is
    // a no-op, leaving focus/cursor untouched.
    if (widget.name != _controller.text) {
      _controller.text = widget.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileField(
      label: 'FULL NAME',
      hintText: 'Enter your name',
      labelColor: AppColors.primaryColor,
      controller: _controller,
      onChanged: widget.onChanged,
      errorText: widget.showError && widget.name.trim().isEmpty
          ? 'Name is required'
          : null,
    );
  }
}
