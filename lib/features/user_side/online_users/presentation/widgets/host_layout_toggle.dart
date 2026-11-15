import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_cubit.dart';
import 'package:mint_talk/features/user_side/home/presentation/bloc/home_state.dart';

/// Round icon button that flips [UserGrid] between grid and list layouts.
/// Shows the icon of the layout it switches *to*.
class HostLayoutToggle extends StatelessWidget {
  const HostLayoutToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isGrid = context.select<HomeCubit, bool>(
      (cubit) => cubit.state.layout == HostLayout.grid,
    );

    return Tooltip(
      message: isGrid ? AppTexts.listView : AppTexts.gridView,
      child: Material(
        color: AppColors.pillUnselected,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.read<HomeCubit>().toggleLayout();
          },
          child: SizedBox(
            width: 34.cw,
            height: 34.cw,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                isGrid ? Icons.view_agenda_rounded : Icons.grid_view_rounded,
                key: ValueKey(isGrid),
                size: 18.csp,
                color: AppColors.plumDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
