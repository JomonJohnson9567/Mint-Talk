import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_cubit.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/cubit/user_profile_edit_state.dart';
import 'package:mint_talk/features/user_side/user_profile_edit/presentation/widgets/user_profile_edit_contents.dart';

class UserProfileEdit extends StatelessWidget {
  const UserProfileEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlue,
      appBar: const CustomAppBar(
        title: 'Edit Profile',
        automaticallyImplyLeading: true,
      ),
      body: BlocConsumer<UserProfileEditCubit, UserProfileEditState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == UserProfileEditStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: AppColors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state.status == UserProfileEditStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == UserProfileEditStatus.initial ||
              state.status == UserProfileEditStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }
          return const UserProfileEditContents();
        },
      ),
    );
  }
}
