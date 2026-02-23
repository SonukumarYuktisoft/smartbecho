import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';

// DatePicker Theme for Light Mode
class AppDatePickerTheme {
  AppDatePickerTheme._();

  static DatePickerThemeData lightDatePickerTheme = DatePickerThemeData(
    // Background colors
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withOpacity(0.1),
    
    // Header styling
    headerBackgroundColor: AppColors.primaryLight,
    headerForegroundColor: Colors.white,
    headerHeadlineStyle: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: 0,
    ),
    headerHelpStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.9),
      letterSpacing: 0.5,
    ),
    
    // Weekday header
    weekdayStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryLight,
    ),
    
    // Day styling
    dayStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey[400];
      }
      return const Color(0xFF1F2937);
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primaryLight.withOpacity(0.1);
      }
      return Colors.transparent;
    }),
    dayOverlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primaryLight.withOpacity(0.2);
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primaryLight.withOpacity(0.1);
      }
      return Colors.transparent;
    }),
    
    // Today's date styling
    todayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return AppColors.primaryLight;
    }),
    todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      return Colors.transparent;
    }),
    todayBorder: BorderSide(
      color: AppColors.primaryLight,
      width: 2,
    ),
    
    // Shape
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    dayShape: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );
      }
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      );
    }),
    
    // Year styling
    yearStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    yearForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return const Color(0xFF1F2937);
    }),
    yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      return Colors.transparent;
    }),
    
    // Range picker colors
    rangePickerBackgroundColor: Colors.white,
    rangePickerHeaderBackgroundColor: AppColors.primaryLight,
    rangePickerHeaderForegroundColor: Colors.white,
    rangeSelectionBackgroundColor: AppColors.primaryLight.withOpacity(0.15),
    
    // Divider
    dividerColor: Colors.grey[200],
    
    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
    ),
    
    // Button styling
    cancelButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      overlayColor: WidgetStateProperty.all(
        AppColors.primaryLight.withOpacity(0.1),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.white),
      backgroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
    ),
  );

  // Dark DatePicker Theme
  static DatePickerThemeData darkDatePickerTheme = DatePickerThemeData(
    backgroundColor: const Color(0xFF1F2937),
    surfaceTintColor: Colors.transparent,
    
    headerBackgroundColor: AppColors.primaryLight,
    headerForegroundColor: Colors.white,
    headerHeadlineStyle: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headerHelpStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white.withOpacity(0.9),
    ),
    
    weekdayStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryLight,
    ),
    
    dayStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    dayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      if (states.contains(WidgetState.disabled)) {
        return Colors.grey[600];
      }
      return Colors.white;
    }),
    dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      return Colors.transparent;
    }),
    
    todayForegroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return AppColors.primaryLight;
    }),
    todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primaryLight;
      }
      return Colors.transparent;
    }),
    todayBorder: BorderSide(
      color: AppColors.primaryLight,
      width: 2,
    ),
    
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    dayShape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    dividerColor: Colors.grey[700],
    
    cancelButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.white),
      backgroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
    ),
  );
}

