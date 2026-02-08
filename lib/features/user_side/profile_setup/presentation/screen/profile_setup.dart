import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/gender_card.dart';
import 'package:mint_talk/features/user_side/profile_setup/presentation/widgets/profile_field.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              // Logo
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    image: DecorationImage(
                      image: AssetImage(AppAssets.profileSetupLogo),
                      fit: BoxFit.cover,
                    ),
                  ),
                  height: 50.h,
                  width: 200.w,
                ),
              ),

              SizedBox(height: 30.h),

              // Title
              Text(
                AppTexts.setupProfile,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppTexts.fillDetails,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  color: AppColors.textGrey,
                ),
              ),

              SizedBox(height: 32.h),

              // Full Name
              const ProfileField(
                label: AppTexts.fullName,
                hintText: AppTexts.alexJohnson,
                suffixIcon: Icon(Icons.check_circle, color: AppColors.green),
              ),

              SizedBox(height: 20.h),

              // Date of Birth
              const ProfileField(
                label: AppTexts.dateOfBirth,
                hintText: AppTexts.dobFormat,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textGrey,
                ),
                readOnly: true, // Typically opens date picker
              ),

              SizedBox(height: 20.h),

              // Referral Code
              const ProfileField(
                label: AppTexts.referralCodeOptional,
                hintText: AppTexts.enterCode,
              ),

              SizedBox(height: 32.h),

              // Gender Selection Title
              Text(
                AppTexts.selectGender,
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  letterSpacing: 0.5,
                ),
              ),

              SizedBox(height: 16.h),

              // Gender Cards Row
              Row(
                children: [
                  Expanded(
                    child: GenderCard(
                      label: AppTexts.male,
                      iconPath: '', // Placeholder
                      isSelected: true, // Example state
                      onTap: () {},
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GenderCard(
                      label: AppTexts.female,
                      iconPath: '', // Placeholder
                      isSelected: false, // Example state
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Warning Text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    AppTexts.wrongGenderBan,
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Submit Button
              PrimaryButton(text: AppTexts.submit, onPressed: () {}),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
