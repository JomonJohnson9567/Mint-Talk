import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_wallet/presentation/widgets/wallet_sheet_handle.dart';

class WithdrawalSuccessBottomSheet extends StatelessWidget {
  const WithdrawalSuccessBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WalletSheetHandle(),
              SizedBox(height: 28.h),
              Container(
                width: 84.w,
                height: 84.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF4E73F8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 48.sp,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: 22.h),
              Text(
                'Withdrawal Initiated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your withdrawal request has been submitted successfully. The amount will be credited to your bank account within 2-3 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: AppColors.subtitleText,
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    minimumSize: Size.fromHeight(54.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
