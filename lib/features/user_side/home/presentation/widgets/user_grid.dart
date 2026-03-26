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

        return LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 3;
            if (constraints.maxWidth >= 1200) {
              crossAxisCount = 6;
            } else if (constraints.maxWidth >= 900) {
              crossAxisCount = 5;
            } else if (constraints.maxWidth >= 600) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth < 350) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
                bottom:
                    100.h +
                    10.h, // Space for bottom nav + original bottom padding
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 15.h,
                mainAxisExtent: 190.h,
              ),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserGridItem(user: user);
              },
            );
          },
        );
      },
    );
  }
}
