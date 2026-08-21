import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mint_talk/core/theme/color.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'home_skeleton.dart';
import 'user_grid_item.dart';

class UserGrid extends StatelessWidget {
  const UserGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.isLoading != current.isLoading ||
          previous.errorMessage != current.errorMessage ||
          previous.hosts != current.hosts,
      builder: (context, state) {
        // Show skeleton while waiting for the initial socket snapshot
        if (state.isLoading) {
          return const HomeSkeleton();
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () => context.read<HomeCubit>().refresh(),
          child: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    // Socket connection error
    if (state.errorMessage != null && state.hosts.isEmpty) {
      return _scrollableMessage(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 40.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Unable to connect. Please check your internet and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.hosts.isEmpty) {
      return _scrollableMessage(
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
          physics: const AlwaysScrollableScrollPhysics(),
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
  }

  /// Wraps a centered message in a scrollable so [RefreshIndicator] can
  /// still be pulled down even when the content doesn't fill the viewport.
  Widget _scrollableMessage({required Widget child}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}
