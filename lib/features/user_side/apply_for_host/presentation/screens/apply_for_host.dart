import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_app_bar.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';
import '../widgets/apply_dob_input.dart';
import '../widgets/apply_name_input.dart';
import '../widgets/apply_selfie_upload.dart';
import '../widgets/apply_submit_button.dart';

class ApplyForHost extends StatelessWidget {
  const ApplyForHost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppBar(
        title: 'Apply for Host',
        automaticallyImplyLeading: true,
      ),
      body: BlocConsumer<ApplyForHostCubit, ApplyForHostState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == ApplyForHostStatus.success) {
            _showSuccessDialog(context);
          } else if (state.status == ApplyForHostStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Submission failed'),
                backgroundColor: AppColors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Host Application',
                    style: GoogleFonts.manrope(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Please fill in your details below to submit your application to become a host.',
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      color: AppColors.subtitleText,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const ApplyNameInput(),
                          SizedBox(height: 20.h),
                          const ApplyDobInput(),
                          SizedBox(height: 24.h),
                          const ApplySelfieUpload(),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                  const ApplySubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 10,
          backgroundColor: AppColors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72.w,
                  width: 72.w,
                  decoration: BoxDecoration(
                    color: AppColors.onlineIndicator.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.onlineIndicator,
                      size: 44.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Application Submitted',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Your application has been submitted successfully. Our team will review your profile within 24 hours.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: AppColors.subtitleText,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 28.h),
                PrimaryButton(
                  text: 'OK',
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // dismiss dialog
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.hostApplicationStatus);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
