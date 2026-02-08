// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/core/constants/app_texts.dart';
import 'package:mint_talk/core/navigations/app_routes.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mint_talk/core/widgets/phone_input_section.dart';
import 'package:mint_talk/core/widgets/primary_button.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/country_selector_cubit.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/widgets/country_picker_sheet.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/country_search_cubit.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/widgets/header_text.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/phone_form_cubit.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/features/user_side/auth/presentation/screens/phone_number/presentation/cubit/phone_form_state.dart';

class ScreenContents extends StatelessWidget {
  const ScreenContents({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Image Section
        Positioned(
          left: 0,
          right: 0,
          bottom: 280.h,
          child: Center(
            child: Hero(
              tag: 'morphing_image',
              flightShuttleBuilder: morphingImageFlightShuttleBuilder,
              child: Image.asset(AppAssets.phoneEntry, fit: BoxFit.contain),
            ),
          ),
        ),
        // Bottom Sheet Section
        Align(
          alignment: Alignment.bottomCenter,
          child: Stack(
            children: [
              // 1. Hero Background (Visual Only)
              Positioned.fill(
                child: Hero(
                  tag: 'morphing_bottom_container',
                  flightShuttleBuilder: morphingContainerFlightShuttleBuilder,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30.r),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 2. The Content
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 80.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      const HeaderText(),
                      SizedBox(height: 20.h),
                      BlocBuilder<CountrySelectorCubit, CountrySelectorState>(
                        builder: (context, countryState) {
                          return BlocBuilder<PhoneFormCubit, PhoneFormState>(
                            builder: (context, phoneState) {
                              return PhoneInputSection(
                                selectedCountry: countryState.country,
                                errorText: phoneState.error,
                                onPhoneChanged: (value) {
                                  context
                                      .read<PhoneFormCubit>()
                                      .phoneNumberChanged(
                                        value,
                                        countryCode:
                                            countryState.country.countryCode,
                                      );
                                },
                                onCountryTap: () async {
                                  final country =
                                      await showModalBottomSheet<Country>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => BlocProvider(
                                          create: (context) =>
                                              CountrySearchCubit()
                                                ..loadCountries(),
                                          child: const CountryPickerSheet(),
                                        ),
                                      );
                                  if (country != null && context.mounted) {
                                    context
                                        .read<CountrySelectorCubit>()
                                        .updateCountry(country);
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: 32.h),
                      BlocBuilder<PhoneFormCubit, PhoneFormState>(
                        builder: (context, state) {
                          return PrimaryButton(
                            text: AppTexts.sendOtp,
                            onPressed: () {
                              if (state.isValid) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.otpVerification,
                                );
                              } else {
                                context.read<PhoneFormCubit>().validate(
                                  countryCode: context
                                      .read<CountrySelectorCubit>()
                                      .state
                                      .country
                                      .countryCode,
                                );
                              }
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
