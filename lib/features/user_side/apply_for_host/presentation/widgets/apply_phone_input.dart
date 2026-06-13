import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mint_talk/core/theme/color.dart';
import 'package:mint_talk/core/widgets/phone_input_section.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/cubit/country_search_cubit.dart';
import 'package:mint_talk/features/auth/presentation/screens/phone_number/presentation/widgets/country_picker_sheet.dart';
import '../cubit/apply_for_host_cubit.dart';
import '../cubit/apply_for_host_state.dart';

class ApplyPhoneInput extends StatelessWidget {
  const ApplyPhoneInput({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApplyForHostCubit>();
    return BlocBuilder<ApplyForHostCubit, ApplyForHostState>(
      buildWhen: (p, c) =>
          p.phone != c.phone ||
          p.selectedCountry != c.selectedCountry ||
          p.fieldErrors['phone'] != c.fieldErrors['phone'],
      builder: (context, state) {
        return PhoneInputSection(
          label: 'PHONE NUMBER',
          labelStyle: GoogleFonts.manrope(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            letterSpacing: 1.2,
          ),
          backgroundColor: AppColors.white,
          border: Border.all(
            color: AppColors.grey.withAlpha(204),
          ),
          borderRadius: 16.r,
          height: 56.h,
          hintStyle: GoogleFonts.manrope(
            fontSize: 14.sp,
            color: AppColors.textGrey,
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          selectedCountry: state.selectedCountry,
          errorText: state.fieldErrors['phone'],
          onPhoneChanged: cubit.phoneChanged,
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
              cubit.countryChanged(country);
            }
          },
        );
      },
    );
  }
}
