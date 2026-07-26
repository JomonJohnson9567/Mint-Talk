import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'home_skeleton.dart';
import 'user_grid_item.dart';

class UserGrid extends StatelessWidget {
  const UserGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // Show skeleton while waiting for the initial socket snapshot
        if (state.isLoading) {
          return const HomeSkeleton();
        }

        // Socket connection error
        if (state.errorMessage != null && state.hosts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 40.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Unable to connect. Please check your internet and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.hosts.isEmpty) {
          return Center(
            child: Text(
              'No hosts found',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          );
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
                bottom: 100.h + 10.h,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 15.h,
                mainAxisExtent: 190.h,
              ),
              itemCount: state.hosts.length,
              itemBuilder: (context, index) {
                final host = state.hosts[index];
                return UserGridItem(host: host);
              },
            );
          },
        );
      },
    );
  }
}
