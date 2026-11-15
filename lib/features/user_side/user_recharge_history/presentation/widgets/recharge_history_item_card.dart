import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/transitions/cubit/snack_bar_state.dart';
import 'package:mint_talk/core/utils/compact_size.dart';
import 'package:mint_talk/core/utils/indian_number_format.dart';
import 'package:mint_talk/core/widgets/top_snackbar.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/domain/entities/recharge_history_item.dart';
import 'package:mint_talk/features/user_side/user_recharge_history/presentation/widgets/recharge_history_status_chip.dart';

/// Cream-white card for one recharge: coins, price, date, status and a
/// tap-to-copy transaction ID.
class RechargeHistoryItemCard extends StatelessWidget {
  final RechargeHistoryItem item;

  const RechargeHistoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item.status.toLowerCase();
    final isPending = status == 'pending' || status == 'processing';
    final isFailed = status == 'failed' || status == 'error';
    final coins = IndianNumberFormat.format(item.points);

    final radius = BorderRadius.circular(18.cw);

    return Container(
      margin: EdgeInsets.only(bottom: 12.cw),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.plumDeep.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      // Material (not a decorated Container) so the Txn ID row's ink ripple
      // paints on the card surface.
      child: Material(
        color: AppColors.cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: AppColors.primaryColor.withValues(alpha: 0.06),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(14.cw, 14.cw, 14.cw, 12.cw),
              child: Row(
                children: [
                  Container(
                    width: 44.cw,
                    height: 44.cw,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.pricePill,
                      borderRadius: BorderRadius.circular(12.cw),
                    ),
                    child: Opacity(
                      opacity: isFailed ? 0.5 : 1,
                      child: Image.asset(
                        AppAssets.rechargeCoin,
                        width: 26.cw,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.cw),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Only completed recharges read as "+N" — pending and
                        // failed ones haven't been credited.
                        Text(
                          isPending || isFailed
                              ? '$coins ${AppTexts.coinsSuffix}'
                              : '+$coins ${AppTexts.coinsSuffix}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5.csp,
                            fontWeight: FontWeight.w800,
                            color: isFailed
                                ? AppColors.plumHint
                                : isPending
                                ? AppColors.plumMuted
                                : AppColors.plumDeep,
                            decoration: isFailed
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: AppColors.plumHint,
                          ),
                        ),
                        SizedBox(height: 4.cw),
                        Text(
                          _formatDate(item.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.csp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.plumHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.cw),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatPrice(item.currency, item.amount),
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15.csp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.plumDeep,
                        ),
                      ),
                      SizedBox(height: 6.cw),
                      RechargeHistoryStatusChip(status: item.status),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 14.cw),
              color: AppColors.primaryColor.withValues(alpha: 0.06),
            ),
            _TransactionIdRow(transactionId: item.transactionId),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(String currency, num amount) {
    final symbol = currency.toUpperCase() == 'INR'
        ? AppTexts.rupeeSymbol
        : currency;
    return '$symbol ${IndianNumberFormat.format(amount)}';
  }

  static String _formatDate(DateTime dateTime) {
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}, '
        '$hour:$minute $period';
  }
}

class _TransactionIdRow extends StatelessWidget {
  final String transactionId;

  const _TransactionIdRow({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final hasId = transactionId.isNotEmpty;

    return InkWell(
      onTap: hasId ? () => _copy(context) : null,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.cw, 10.cw, 14.cw, 12.cw),
        child: Row(
          children: [
            Text(
              AppTexts.txnId,
              style: TextStyle(
                fontSize: 10.5.csp,
                fontWeight: FontWeight.w700,
                color: AppColors.plumHint,
              ),
            ),
            SizedBox(width: 8.cw),
            Expanded(
              child: Text(
                hasId ? transactionId : AppTexts.unavailable,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5.csp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.plumMuted,
                ),
              ),
            ),
            if (hasId) ...[
              SizedBox(width: 8.cw),
              Icon(
                Icons.copy_rounded,
                size: 16.csp,
                color: AppColors.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: transactionId));
    if (!context.mounted) return;
    showTopSnackBar(context, AppTexts.txnIdCopied, type: SnackBarType.success);
  }
}
