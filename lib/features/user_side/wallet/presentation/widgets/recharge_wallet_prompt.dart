import 'package:flutter/material.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/confirmation_dialog.dart';

/// "Recharge Wallet" modal shown when the caller doesn't have enough points —
/// either before a call (pre-call guard / HTTP 400 from /calls/initiate) or
/// after the backend drops a call because the balance ran out.
Future<void> showRechargeWalletPrompt(BuildContext context, {String? message}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => ConfirmationDialog(
      icon: Icons.account_balance_wallet_rounded,
      iconColor: AppColors.primaryColor,
      accentColor: AppColors.primaryColor,
      title: 'Recharge Wallet',
      content: (message != null && message.isNotEmpty)
          ? message
          : "You don't have enough points for this call. Recharge your wallet to continue.",
      confirmButtonText: 'Recharge',
      cancelButtonText: 'Not now',
      onConfirm: () {
        final navigator = Navigator.of(dialogContext);
        navigator.pop();
        navigator.pushNamed(AppRoutes.rechargePlansScreen);
      },
    ),
  );
}
