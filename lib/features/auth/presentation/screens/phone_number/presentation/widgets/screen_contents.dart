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
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/country_selector_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/widgets/country_picker_sheet.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/country_search_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/widgets/header_text.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/phone_form_cubit.dart';
import 'package:mint_talk/core/transitions/utils/morphing_flight_shuttle.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/phone_form_state.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/widgets/legal_footer.dart';
import 'package:mint_talk/core/widgets/mint_talk_logo.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/widgets/wave_top_clipper.dart';

class ScreenContents extends StatelessWidget {
  const ScreenContents({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final waveDepth = 40.h;

    return BlocListener<PhoneFormCubit, PhoneFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == PhoneFormStatus.otpSent) {
          final countryState = context.read<CountrySelectorCubit>().state;
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerification,
            arguments: {
              'phone': state.phoneNumber,
              'countryCode': countryState.country.phoneCode,
            },
          );
          // Reset status so navigating back doesn't re-trigger
          context.read<PhoneFormCubit>().resetStatus();
        } else if (state.status == PhoneFormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.apiErrorMessage ?? 'Something went wrong'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        } else if (state.status == PhoneFormStatus.rateLimited) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.apiErrorMessage ?? 'Too many requests. Please wait.',
              ),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The illustration bleeds slightly past both screen edges so the
          // five mascots fill the space above the card, as in the design.
          final mascotBleed = constraints.maxWidth * 0.03;

          return Stack(
            children: [
              // Mascot illustration, faded into the cream background at the top
              Positioned(
                top: padding.top + 2.h,
                left: -mascotBleed,
                right: -mascotBleed,
                child: Hero(
                  tag: 'morphing_image',
                  flightShuttleBuilder: morphingImageFlightShuttleBuilder,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 0.15],
                    ).createShader(rect),
                    child: Image.asset(
                      AppAssets.loginMascots,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: padding.top + 2.h,
                left: 0,
                right: 0,
                child: const Center(child: MintTalkLogo()),
              ),
              // Wave-topped card
              Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight),
                  child: Stack(
                    children: [
                      // 1. Hero Background (Visual Only)
                      Positioned.fill(
                        child: Hero(
                          tag: 'morphing_bottom_container',
                          flightShuttleBuilder:
                              morphingContainerFlightShuttleBuilder,
                          child: Material(
                            color: Colors.transparent,
                            child: ClipPath(
                              clipper: WaveTopClipper(depth: waveDepth),
                              child: const ColoredBox(
                                color: AppColors.cardWhite,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 2. The Content
                      SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20.w,
                          waveDepth - 4.h,
                          20.w,
                          padding.bottom + 8.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const HeaderText(),
                            SizedBox(height: 24.h),
                            _buildPhoneInput(),
                            SizedBox(height: 22.h),
                            _buildSendOtpButton(),
                            SizedBox(height: 12.h),
                            const LegalFooter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPhoneInput() {
    return BlocBuilder<CountrySelectorCubit, CountrySelectorState>(
      builder: (context, countryState) {
        return BlocBuilder<PhoneFormCubit, PhoneFormState>(
          builder: (context, phoneState) {
            return PhoneInputSection(
              selectedCountry: countryState.country,
              errorText: phoneState.error,
              helperText: AppTexts.weWillSendCode,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.plumDeep,
              ),
              backgroundColor: AppColors.white,
              border: Border.all(color: AppColors.lavenderBorder, width: 1.5),
              borderRadius: 16.r,
              height: 50.h,
              accentColor: AppColors.plumDeep,
              dividerColor: AppColors.lavenderBorder,
              textStyle: TextStyle(
                fontSize: 15.sp,
                color: AppColors.plumDeep,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(
                fontSize: 15.sp,
                color: AppColors.plumHint,
                fontWeight: FontWeight.w400,
              ),
              helperStyle: TextStyle(
                fontSize: 12.sp,
                color: AppColors.plumMuted,
              ),
              onPhoneChanged: (value) {
                context.read<PhoneFormCubit>().phoneNumberChanged(
                  value,
                  countryCode: countryState.country.countryCode,
                );
              },
              onCountryTap: () async {
                final country = await showModalBottomSheet<Country>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BlocProvider(
                    create: (context) => CountrySearchCubit()..loadCountries(),
                    child: const CountryPickerSheet(),
                  ),
                );
                if (country != null && context.mounted) {
                  context.read<CountrySelectorCubit>().updateCountry(country);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSendOtpButton() {
    return BlocBuilder<PhoneFormCubit, PhoneFormState>(
      builder: (context, state) {
        final isLoading = state.status == PhoneFormStatus.loading;

        return PrimaryButton(
          text: isLoading ? 'Sending...' : AppTexts.sendOtp,
          height: 50.h,
          trailingIcon: Icons.arrow_forward_rounded,
          textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          onPressed: isLoading
              ? null
              : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final country = context
                      .read<CountrySelectorCubit>()
                      .state
                      .country;
                  if (state.isValid) {
                    context.read<PhoneFormCubit>().sendOtp(
                      phone: state.phoneNumber,
                      countryCode: country.phoneCode,
                    );
                  } else {
                    context.read<PhoneFormCubit>().validate(
                      countryCode: country.countryCode,
                    );
                  }
                },
        );
      },
    );
  }
}
