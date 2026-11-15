import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/user_side/onboard/presentation/cubit/welcome/welcome_cubit.dart';

class AgreeCheckboxRow extends StatelessWidget {
  const AgreeCheckboxRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WelcomeCubit, WelcomeState, bool>(
      selector: (state) => state.isAgreed,
      builder: (context, isAgreed) {
        // The whole row is the tap target, not just the box.
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.read<WelcomeCubit>().toggleAgreement(!isAgreed),
          child: Row(
            children: [
              SizedBox(
                height: 24.w,
                width: 24.w,
                child: Checkbox(
                  value: isAgreed,
                  activeColor: AppColors.primaryColor,
                  checkColor: AppColors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    context.read<WelcomeCubit>().toggleAgreement(value);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  side: BorderSide(color: AppColors.primaryColor, width: 1.5.w),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  AppTexts.iAgreeToTerms,
                  style: TextStyle(
                    color: AppColors.plumDeep,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
