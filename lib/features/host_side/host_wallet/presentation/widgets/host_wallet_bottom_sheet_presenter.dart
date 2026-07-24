import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/add_bank_bottom_sheet.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/select_bank_bottom_sheet.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdraw_amount_bottom_sheet.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/withdrawal_success_bottom_sheet.dart';

class HostWalletBottomSheetPresenter {
  HostWalletBottomSheetPresenter._();

  static Future<void> showSelectBankSheet(BuildContext context) {
    final cubit = context.read<HostWalletCubit>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: SelectBankBottomSheet(rootContext: context),
      ),
    );
  }

  static Future<void> showAddBankSheet(BuildContext context) {
    final cubit = context.read<HostWalletCubit>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddBankBottomSheet(rootContext: context),
      ),
    );
  }

  static Future<void> showWithdrawAmountSheet(BuildContext context) {
    final cubit = context.read<HostWalletCubit>();
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: WithdrawAmountBottomSheet(rootContext: context),
      ),
    );
  }

  static Future<void> showWithdrawalSuccessSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WithdrawalSuccessBottomSheet(),
    );
  }
}
