import 'package:flutter/material.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/utils/compact_size.dart';

/// Fixed plum pill at the bottom of the wallet. Disabled (null [onTap])
/// whenever a withdrawal can't be started; [notice] then says why in place
/// of the footer line.
class WithdrawMoneyButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final bool isBusy;
  final String? notice;

  const WithdrawMoneyButton({
    super.key,
    this.onTap,
    this.label = AppTexts.withdrawMoney,
    this.isBusy = false,
    this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null && !isBusy;
    final radius = BorderRadius.circular(28.cw);
    final foreground = isEnabled
        ? AppColors.white
        : AppColors.white.withValues(alpha: 0.85);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.cw, 8.cw, 16.cw, 12.cw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: AppColors.transparent,
              child: InkWell(
                onTap: isEnabled ? onTap : null,
                borderRadius: radius,
                child: Ink(
                  height: 54.cw,
                  decoration: BoxDecoration(
                    gradient: isEnabled
                        ? const LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.hostGoOnlineStart,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          )
                        : null,
                    color: isEnabled
                        ? null
                        : AppColors.primaryColor.withValues(alpha: 0.22),
                    borderRadius: radius,
                    boxShadow: isEnabled
                        ? [
                            BoxShadow(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.28,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isBusy
                        ? SizedBox(
                            width: 22.cw,
                            height: 22.cw,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: AppColors.primaryColor,
                            ),
                          )
                        : Text(
                            label,
                            style: TextStyle(
                              fontSize: 17.csp,
                              fontWeight: FontWeight.w700,
                              color: foreground,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.cw),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  notice == null
                      ? Icons.lock_rounded
                      : Icons.info_outline_rounded,
                  size: 14.csp,
                  color: AppColors.hostSubtitle,
                ),
                SizedBox(width: 6.cw),
                Flexible(
                  child: Text(
                    notice ?? AppTexts.transfersToVerifiedAccount,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.csp,
                      color: AppColors.hostSubtitle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
