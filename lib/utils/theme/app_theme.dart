import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/theme/widgets/app_bar_theme.dart';
import 'package:smartbecho/utils/theme/widgets/app_date_picker_theme.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    primarySwatch: AppColors.primarySwatch,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: Colors.white,
    indicatorColor: AppColors.primaryLight,

    visualDensity: VisualDensity.adaptivePlatformDensity,

    fontFamily: GoogleFonts.poppins().fontFamily,

    // ✅ AppBar
    appBarTheme: AppBarTm.light,

    // ✅ Text selection (transparent + clean)
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryLight,
      selectionColor: AppColors.primaryLight.withOpacity(0.2),
      selectionHandleColor: AppColors.primaryLight,
    ),

    // ✅ Progress indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.primaryLight.withOpacity(0.1),
      circularTrackColor: AppColors.primaryLight.withOpacity(0.1),
      refreshBackgroundColor: Colors.white,

      strokeWidth: 2,
    ),

    // ✅ DatePicker
    datePickerTheme: AppDatePickerTheme.lightDatePickerTheme,
  );
}
