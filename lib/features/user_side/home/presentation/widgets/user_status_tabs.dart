import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class UserStatusTabs extends StatelessWidget {
  /// Tabs to show, in order. Defaults to the home page's set.
  final List<(HomeTab, String)> tabs;

  const UserStatusTabs({
    super.key,
    this.tabs = const [
      (HomeTab.active, AppTexts.active),
      (HomeTab.favorites, AppTexts.favorites),
      (HomeTab.offline, AppTexts.offline),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.cw, vertical: 5.cw),
          child: Row(
            children: [
              for (final (index, (tab, title)) in tabs.indexed) ...[
                if (index > 0) SizedBox(width: 8.cw),
                _buildTab(context, title, tab, state.selectedTab == tab),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    HomeTab tab,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<HomeCubit>().changeTab(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 34.cw,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.pillUnselected,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.symmetric(horizontal: 8.cw),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: TextStyle(
                fontSize: 13.csp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.plumDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
