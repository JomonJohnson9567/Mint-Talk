import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/domain/entities/host_bank_account.dart';

class BankAccountCard extends StatelessWidget {
  final HostBankAccount bankAccount;
  final bool isSelected;
  final VoidCallback onTap;

  const BankAccountCard({
    super.key,
    required this.bankAccount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primaryColor : const Color(0xFFF1C26B);
    final surfaceColor = isSelected ? const Color(0xFFF6F7FF) : AppColors.white;

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor, width: 1.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      bankAccount.bankName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        'Selected',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              _InfoRow(label: 'Account Holder', value: bankAccount.accountHolderName),
              SizedBox(height: 8.h),
              _InfoRow(label: 'Account Number', value: bankAccount.maskedAccountNumber),
              SizedBox(height: 8.h),
              _InfoRow(label: 'IFSC Code', value: bankAccount.ifscCode),
              SizedBox(height: 8.h),
              _InfoRow(label: 'Branch', value: bankAccount.branchName),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitleText,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
