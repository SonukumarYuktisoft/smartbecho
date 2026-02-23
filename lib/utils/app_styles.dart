import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartbecho/utils/app_colors.dart';

class AppStyles {
  static TextStyle _roboto({
    Color? color,
    double? size,
    FontWeight? weight,
    double? letterSpacing,
  }) {
    return GoogleFonts.roboto(
      color: color,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
    );
  }

  // Black styles
  static final black_12_400 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 12,
    weight: FontWeight.w400,
  );
  static final black_14_400 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 14,
    weight: FontWeight.w400,
  );
  static final black_14_600 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 14,
    weight: FontWeight.w600,
  );

  static final black_20_300 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 20,
    weight: FontWeight.w300,
  );
  static final black_30_600 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 30,
    weight: FontWeight.w600,
  );

  // Add all other styles similarly...

  // White styles
  static final white_14_400 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 14,
    weight: FontWeight.w400,
  );
  static final white_18_600 = _roboto(
    color: AppColors.onBackgroundLight,
    size: 18,
    weight: FontWeight.w600,
  );

  // Custom color styles
  static TextStyle custom({
    Color? color,
    double? size,
    FontWeight? weight,
    double? letterSpacing,
  }) => _roboto(
    color: color,
    size: size,
    weight: weight,
    letterSpacing: letterSpacing,
  );
}
