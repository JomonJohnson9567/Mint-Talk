import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        surface: AppColors.white,
      ),
      textTheme: GoogleFonts.manropeTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        titleLarge: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: AppColors.black,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: AppColors.subtitleText,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
      ),
    );
  }
}
