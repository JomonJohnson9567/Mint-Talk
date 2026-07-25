import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import '../cubit/host_profile_edit_cubit.dart';
import '../cubit/host_profile_edit_state.dart';
import '../widgets/host_profile_edit_contents.dart';

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
        listenWhen: (previous, current) => previous.status != current.status,
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
          return const HostProfileEditContents();
        },
      ),
    );
  }
}