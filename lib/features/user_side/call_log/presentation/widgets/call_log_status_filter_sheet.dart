import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_state.dart';

/// Opens the All / Completed / Missed sheet behind the app bar's tune icon.
Future<void> showCallLogStatusFilterSheet(BuildContext context) {
  // The sheet's route sits above MainNavigationScreen's providers, so the
  // cubit is handed over explicitly.
  final cubit = context.read<CallLogCubit>();
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const CallLogStatusFilterSheet(),
    ),
  );
}

class CallLogStatusFilterSheet extends StatelessWidget {
  const CallLogStatusFilterSheet({super.key});

  static const _labels = {
    CallLogStatusFilter.all: AppTexts.filterAll,
    CallLogStatusFilter.completed: AppTexts.completed,
    CallLogStatusFilter.missed: AppTexts.missed,
  };

  @override
  Widget build(BuildContext context) {
    final selected = context.select<CallLogCubit, CallLogStatusFilter>(
      (cubit) => cubit.state.statusFilter,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.cw)),
      ),
      padding: EdgeInsets.fromLTRB(20.cw, 12.cw, 20.cw, 20.cw),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.cw,
                height: 4.cw,
                decoration: BoxDecoration(
                  color: AppColors.lavenderBorder,
                  borderRadius: BorderRadius.circular(2.cw),
                ),
              ),
            ),
            SizedBox(height: 16.cw),
            Text(
              AppTexts.filterCalls,
              style: GoogleFonts.nunito(
                fontSize: 19.csp,
                fontWeight: FontWeight.w800,
                color: AppColors.plumDeep,
              ),
            ),
            SizedBox(height: 8.cw),
            for (final filter in CallLogStatusFilter.values)
              _FilterTile(
                label: _labels[filter]!,
                isSelected: filter == selected,
                onTap: () {
                  context.read<CallLogCubit>().setStatusFilter(filter);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.cw),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.cw, vertical: 14.cw),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.csp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.plumDeep,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 22.csp,
              color: isSelected ? AppColors.primaryColor : AppColors.plumHint,
            ),
          ],
        ),
      ),
    );
  }
}
