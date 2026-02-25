import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'user_grid_item.dart';

class UserGrid extends StatelessWidget {
  const UserGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.users.isEmpty) {
          return const Center(child: Text("No users found"));
        }

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15.w,
            mainAxisSpacing: 15.h,
            childAspectRatio: 0.70, // Adjusted to prevent overflow
          ),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];
            return UserGridItem(user: user);
          },
        );
      },
    );
  }
}
