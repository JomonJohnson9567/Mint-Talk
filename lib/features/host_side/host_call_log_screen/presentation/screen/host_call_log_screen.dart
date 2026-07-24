import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/di/injection.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/cubit/host_call_log_cubit.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/cubit/host_call_log_filter_cubit.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/widgets/host_call_log_contents.dart';
import 'package:mint_talk/features/host_side/host_call_log_screen/presentation/widgets/host_call_log_filter_tabs.dart';

class HostCallLogScreen extends StatelessWidget {
  const HostCallLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HostCallLogCubit>()),
        BlocProvider(create: (_) => HostCallLogFilterCubit()),
      ],
      child: const _HostCallLogView(),
    );
  }
}

class _HostCallLogView extends StatelessWidget {
  const _HostCallLogView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: AppTexts.callLog,
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<HostCallLogFilterCubit, HostCallFilterType>(
        builder: (context, selectedFilter) {
          return HostCallLogContents(
            selectedFilter: selectedFilter,
            onFilterChanged:
                context.read<HostCallLogFilterCubit>().changeFilter,
          );
        },
      ),
    );
  }
}
