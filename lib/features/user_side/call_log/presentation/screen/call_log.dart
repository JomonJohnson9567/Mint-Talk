import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_cubit.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/bloc/call_log_state.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_contents.dart';
import 'package:mint_talk/features/user_side/call_log/presentation/widgets/call_log_status_filter_sheet.dart';

class CallLogScreen extends StatelessWidget {
  const CallLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.rechargeBackground,
      appBar: CustomAppBar(
        title: AppTexts.callHistory,
        automaticallyImplyLeading: false,
        centerTitle: false,
        foregroundColor: AppColors.plumDeep,
        actions: [_StatusFilterButton()],
      ),
      body: SafeArea(bottom: false, child: CallLogContents()),
    );
  }
}

/// Tune icon that opens the status sheet; a dot marks an active filter.
class _StatusFilterButton extends StatelessWidget {
  const _StatusFilterButton();

  @override
  Widget build(BuildContext context) {
    final isFiltered = context.select<CallLogCubit, bool>(
      (cubit) => cubit.state.statusFilter != CallLogStatusFilter.all,
    );

    return Padding(
      padding: EdgeInsets.only(right: 6.cw),
      child: IconButton(
        tooltip: AppTexts.filterCalls,
        onPressed: () => showCallLogStatusFilterSheet(context),
        icon: Badge(
          isLabelVisible: isFiltered,
          backgroundColor: AppColors.audioAccent,
          smallSize: 8.cw,
          child: Icon(Icons.tune_rounded, size: 26.csp),
        ),
      ),
    );
  }
}
