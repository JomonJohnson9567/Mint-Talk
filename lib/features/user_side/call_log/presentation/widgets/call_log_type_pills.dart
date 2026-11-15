import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_state.dart';

/// All / Audio / Video filter pills.
class CallLogTypePills extends StatelessWidget {
  const CallLogTypePills({super.key});

  static const _labels = {
    CallLogTypeFilter.all: AppTexts.filterAll,
    CallLogTypeFilter.audio: AppTexts.filterAudio,
    CallLogTypeFilter.video: AppTexts.filterVideo,
  };

  @override
  Widget build(BuildContext context) {
    final selected = context.select<CallLogCubit, CallLogTypeFilter>(
      (cubit) => cubit.state.typeFilter,
    );

    return Row(
      children: [
        for (final filter in CallLogTypeFilter.values) ...[
          if (filter != CallLogTypeFilter.values.first) SizedBox(width: 10.cw),
          Expanded(
            child: _Pill(
              label: _labels[filter]!,
              isSelected: filter == selected,
              onTap: () => context.read<CallLogCubit>().setTypeFilter(filter),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.cw);

    return Material(
      color: isSelected ? AppColors.primaryColor : AppColors.audioBtnBg,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: SizedBox(
          height: 44.cw,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.5.csp,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.white : AppColors.plumDeep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
