import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_cubit.dart';
import 'package:mint_talk/features/host_side/host_profile_setup/presentation/cubit/host_profile_setup_state.dart';

class PreferredCategories extends StatelessWidget {
  const PreferredCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> categories = AppTexts.hostCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.preferredCategories,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.grey.withAlpha(77)),
          ),
          child: BlocBuilder<HostProfileSetupCubit, HostProfileSetupState>(
            builder: (context, state) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 36.h,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = state.selectedCategories.contains(category);

                  return InkWell(
                    onTap: () {
                      context.read<HostProfileSetupCubit>().toggleCategory(category);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              context
                                  .read<HostProfileSetupCubit>()
                                  .toggleCategory(category);
                            },
                            activeColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            side: BorderSide(
                              color: AppColors.grey.withAlpha(128),
                              width: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            category,
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              color: AppColors.black.withAlpha(179),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
